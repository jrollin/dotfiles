# Supabase Sync Reference

Complete database schema and sync patterns for storing Stripe data in Supabase.

## Three Approaches to Stripe Data

Supabase offers three ways to access Stripe data:

### Comparison

| Aspect | Stripe Sync Engine | Webhook Sync | Stripe Wrapper (FDW) |
|--------|-------------------|--------------|----------------------|
| **How it works** | One-click integration, auto-syncs to `stripe.*` schema | Stripe pushes events to your webhook, you store in local tables | SQL queries translated to Stripe API calls in real-time |
| **Setup** | Dashboard → Integrations → Install | Write webhook handlers | SQL configuration |
| **Maintenance** | Supabase managed | You manage | Supabase managed |
| **Data freshness** | Real-time (webhooks) + scheduled backfills | Near real-time (webhook delay) | Always current (live API) |
| **Query speed** | Fast (local database, indexed JSONB) | Fast (local database) | Slower (API call per query) |
| **Offline access** | Yes | Yes | No (requires Stripe API) |
| **Rate limits** | No concerns (batched imports) | No concerns | Subject to Stripe API limits |
| **Custom fields** | JSONB metadata accessible | Can add any columns | Limited to Stripe's schema |
| **RLS support** | JSONB-based policies | Full RLS policies | Limited (read-only foreign tables) |
| **Schema** | `stripe.*` (auto-created) | Custom `public.*` tables | Foreign tables |
| **Best for** | Most apps (recommended) | Custom business logic | Admin queries, prototyping |

### When to Use Each

**Use Stripe Sync Engine (recommended for most apps) when:**
- You want zero-maintenance Stripe data syncing
- You need fast queries on synced data
- You want both real-time updates and historical backfills
- You're okay with the `stripe.*` schema structure
- You want to query Stripe data with standard SQL

**Use Webhook Sync when:**
- You need custom table schemas or business logic
- You want to transform data during sync
- You need full RLS policies on Stripe data
- You're building complex customer-facing billing UI
- You need to join Stripe data with your tables frequently

**Use Stripe Wrapper (FDW) when:**
- You need always-current data (admin reports)
- You're doing occasional/ad-hoc queries
- You want minimal setup for prototyping
- You're building internal admin tools
- You don't need complex joins or RLS

**Combine approaches when:**
- Sync Engine for general Stripe data access
- Webhook sync for custom transformations or specific tables
- Stripe Wrapper for real-time admin queries

---

## Stripe Sync Engine (Official Integration)

Supabase's official one-click integration that automatically syncs Stripe data to your database.

### Setup (4 Steps)

1. Navigate to **Integrations** in your Supabase project dashboard
2. Find **Stripe Sync Engine** and click **Install**
3. Provide your Stripe API key (use a restricted key with webhook endpoint write access)
4. Syncing begins automatically

### How It Works

**Architecture:**
- Uses **Supabase Queues (pgmq)** for reliable, batched data import
- **Edge Functions** handle concurrent Stripe API fetches with automatic retry logic
- **Initial backfill** syncs historical data (minutes to hours depending on account size)
- **Webhooks** capture real-time events immediately after setup

**Data Storage:**
- Creates a `stripe` schema with JSONB storage
- Generated columns provide type-safe access to common fields
- Indexed for fast querying

### Schema Created

The integration creates a `stripe` schema with tables:

```sql
-- Example tables created automatically
stripe.customers
stripe.subscriptions
stripe.invoices
stripe.prices
stripe.products
stripe.payment_intents
stripe.charges
-- ... and more
```

### Querying Sync Engine Data

```sql
-- Get all active subscriptions
SELECT * FROM stripe.subscriptions
WHERE status = 'active';

-- Get customer with email
SELECT * FROM stripe.customers
WHERE email = 'user@example.com';

-- Join with your tables
SELECT
  u.id,
  u.email,
  s.status,
  s.current_period_end
FROM auth.users u
LEFT JOIN stripe.customers c ON c.email = u.email
LEFT JOIN stripe.subscriptions s ON s.customer = c.id
WHERE s.status = 'active';
```

### Business Analytics Queries

These queries demonstrate the power of having Stripe data in your database:

**Find unconverted signups (users who signed up but never subscribed):**

```sql
SELECT
  users.email,
  users.created_at AS signed_up,
  NOW() - users.created_at AS days_since_signup
FROM auth.users
LEFT JOIN stripe.customers ON customers.email = users.email
LEFT JOIN stripe.subscriptions ON subscriptions.customer = customers.id
WHERE subscriptions.id IS NULL
  AND users.created_at < NOW() - INTERVAL '7 days'
ORDER BY users.created_at;
```

**Calculate MRR (Monthly Recurring Revenue) by plan:**

```sql
SELECT
  products.name AS plan,
  COUNT(*) AS subscribers,
  SUM(prices.unit_amount) / 100.0 AS mrr
FROM stripe.subscriptions
JOIN stripe.prices ON prices.id = (subscriptions.plan::json->'id')::text
JOIN stripe.products ON products.id = prices.product
WHERE subscriptions.status = 'active'
GROUP BY products.name
ORDER BY mrr DESC;
```

**Identify at-risk accounts (active subscribers who haven't been active recently):**

```sql
SELECT
  customers.email,
  subscriptions.current_period_end AS renewal_date,
  MAX(user_events.created_at) AS last_active
FROM stripe.customers
JOIN stripe.subscriptions ON subscriptions.customer = customers.id
JOIN public.user_events ON user_events.user_id = customers.metadata->>'user_id'
WHERE subscriptions.status = 'active'
GROUP BY customers.email, subscriptions.current_period_end
HAVING MAX(user_events.created_at) < NOW() - INTERVAL '30 days'
ORDER BY subscriptions.current_period_end;
```

**Revenue by month:**

```sql
SELECT
  DATE_TRUNC('month', created) AS month,
  SUM(amount) / 100.0 AS revenue
FROM stripe.charges
WHERE status = 'succeeded'
GROUP BY DATE_TRUNC('month', created)
ORDER BY month DESC;
```

### When to Add Custom Tables

Even with Sync Engine, you may want custom tables for:
- Mapping Stripe customer IDs to your user IDs
- Storing computed billing status for fast access
- Caching subscription tier for RLS policies

```sql
-- Example: Custom customers mapping table
CREATE TABLE public.customer_mapping (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  stripe_customer_id TEXT UNIQUE NOT NULL,
  subscription_tier TEXT DEFAULT 'free',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync tier from Stripe data
CREATE OR REPLACE FUNCTION sync_subscription_tier()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.customer_mapping
  SET subscription_tier = CASE
    WHEN EXISTS (
      SELECT 1 FROM stripe.subscriptions s
      WHERE s.customer = NEW.stripe_customer_id
      AND s.status IN ('active', 'trialing')
    ) THEN 'pro'
    ELSE 'free'
  END
  WHERE stripe_customer_id = NEW.stripe_customer_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

### Stripe Wrapper Quick Setup

```sql
-- 1. Enable the extension
create extension if not exists wrappers with schema extensions;

-- 2. Create the foreign data wrapper
create foreign data wrapper stripe_wrapper
  handler stripe_fdw_handler
  validator stripe_fdw_validator;

-- 3. Store API key in Vault (recommended)
insert into vault.secrets (id, name, secret)
values (
  'stripe_key',
  'stripe',
  'sk_test_xxx'  -- Your Stripe secret key
);

-- 4. Create server connection
create server stripe_server
  foreign data wrapper stripe_wrapper
  options (
    api_key_id 'stripe_key'  -- Reference to Vault secret
  );

-- 5. Create foreign tables
create foreign table stripe.customers (
  id text,
  email text,
  name text,
  created timestamp
)
server stripe_server
options (object 'customers');

create foreign table stripe.subscriptions (
  id text,
  customer text,
  status text,
  current_period_start timestamp,
  current_period_end timestamp
)
server stripe_server
options (object 'subscriptions');

-- 6. Query Stripe data directly
select * from stripe.customers where email = 'user@example.com';
select * from stripe.subscriptions where status = 'active';
```

### Hybrid Approach Example

```sql
-- Local synced table for fast customer-facing queries
select
  s.status,
  s.current_period_end,
  p.name as plan_name
from subscriptions s
join prices pr on s.price_id = pr.id
join products p on pr.product_id = p.id
where s.customer_id = auth.uid();

-- Stripe Wrapper for admin real-time data
select
  id,
  amount_due,
  status
from stripe.invoices
where customer = 'cus_xxx'
order by created desc
limit 10;
```

---

**The rest of this guide covers the Webhook Sync approach**, which is recommended for most production applications.

## Schema Overview

Using the hybrid ID approach:
- **User-linked tables**: UUID as PK (from auth.users), nanoid as public_id
- **Standalone tables**: nanoid as PK

```
┌─────────────────┐     ┌─────────────────┐
│   auth.users    │     │    customers    │
├─────────────────┤     ├─────────────────┤
│ id (UUID) PK    │<────│ user_id (UUID)  │ PK + FK
│                 │     │ public_id       │ nanoid
│                 │     │ stripe_customer │
└─────────────────┘     └─────────────────┘
                               │
                               │
┌─────────────────┐     ┌──────┴──────────┐
│    products     │     │  subscriptions  │
├─────────────────┤     ├─────────────────┤
│ id (nanoid) PK  │     │ id (nanoid) PK  │
│ stripe_product  │     │ stripe_sub      │
└─────────────────┘     │ customer_id FK  │
        │               │ price_id FK     │
        │               └─────────────────┘
        │
┌───────┴─────────┐
│     prices      │
├─────────────────┤
│ id (nanoid) PK  │
│ stripe_price    │
│ product_id FK   │
└─────────────────┘
```

## Complete Migration

Create a single migration file with all tables:

```bash
npx supabase migration new stripe_tables
```

```sql
-- =====================================================
-- STRIPE INTEGRATION TABLES
-- =====================================================

-- Prerequisites: nanoid function (see postgres-nanoid skill)
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- TABLE: customers
-- Links Supabase auth.users to Stripe customers
-- =====================================================

CREATE TABLE IF NOT EXISTS public.customers (
    -- Primary key linked to auth.users
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Public identifier for APIs
    public_id TEXT UNIQUE NOT NULL DEFAULT nanoid('cus_'),

    -- Stripe reference
    stripe_customer_id TEXT UNIQUE NOT NULL,

    -- Customer details (synced from Stripe)
    email TEXT,
    name TEXT,

    -- Billing
    default_payment_method TEXT,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT customers_public_id_format CHECK (public_id ~ '^cus_[0-9a-zA-Z]{17}$'),
    CONSTRAINT customers_stripe_id_format CHECK (stripe_customer_id ~ '^cus_')
);

COMMENT ON TABLE public.customers IS 'Stripe customers linked to auth.users';
COMMENT ON COLUMN public.customers.user_id IS 'Internal ID - use for RLS and joins';
COMMENT ON COLUMN public.customers.public_id IS 'Public ID for APIs (nanoid)';
COMMENT ON COLUMN public.customers.stripe_customer_id IS 'Stripe customer ID';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_customers_stripe_id ON public.customers(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_customers_public_id ON public.customers(public_id);

-- RLS
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own customer record"
    ON public.customers FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = user_id);

-- =====================================================
-- TABLE: products
-- Synced from Stripe products
-- =====================================================

CREATE TABLE IF NOT EXISTS public.products (
    -- nanoid primary key
    id TEXT PRIMARY KEY DEFAULT nanoid('prd_'),

    -- Stripe reference
    stripe_product_id TEXT UNIQUE NOT NULL,

    -- Product details
    name TEXT NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT true,

    -- Images
    images TEXT[] DEFAULT '{}',

    -- Features (for pricing page)
    features TEXT[] DEFAULT '{}',

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT products_id_format CHECK (id ~ '^prd_[0-9a-zA-Z]{17}$'),
    CONSTRAINT products_stripe_id_format CHECK (stripe_product_id ~ '^prod_')
);

COMMENT ON TABLE public.products IS 'Stripe products synced via webhooks';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_stripe_id ON public.products(stripe_product_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(active);

-- RLS (public read for active products)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active products"
    ON public.products FOR SELECT
    TO authenticated, anon
    USING (active = true);

-- =====================================================
-- TABLE: prices
-- Synced from Stripe prices
-- =====================================================

CREATE TABLE IF NOT EXISTS public.prices (
    -- nanoid primary key
    id TEXT PRIMARY KEY DEFAULT nanoid('pri_'),

    -- Stripe reference
    stripe_price_id TEXT UNIQUE NOT NULL,

    -- Product reference
    product_id TEXT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,

    -- Price details
    active BOOLEAN NOT NULL DEFAULT true,
    currency TEXT NOT NULL DEFAULT 'usd',
    unit_amount INTEGER, -- in cents

    -- Recurring details
    type TEXT NOT NULL DEFAULT 'recurring' CHECK (type IN ('one_time', 'recurring')),
    interval TEXT CHECK (interval IN ('day', 'week', 'month', 'year')),
    interval_count INTEGER DEFAULT 1,

    -- Usage/metered billing
    usage_type TEXT CHECK (usage_type IN ('licensed', 'metered')),
    billing_scheme TEXT CHECK (billing_scheme IN ('per_unit', 'tiered')),

    -- Tiers (for tiered pricing)
    tiers JSONB,
    tiers_mode TEXT CHECK (tiers_mode IN ('graduated', 'volume')),

    -- Trial
    trial_period_days INTEGER,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT prices_id_format CHECK (id ~ '^pri_[0-9a-zA-Z]{17}$'),
    CONSTRAINT prices_stripe_id_format CHECK (stripe_price_id ~ '^price_')
);

COMMENT ON TABLE public.prices IS 'Stripe prices synced via webhooks';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_prices_stripe_id ON public.prices(stripe_price_id);
CREATE INDEX IF NOT EXISTS idx_prices_product_id ON public.prices(product_id);
CREATE INDEX IF NOT EXISTS idx_prices_active ON public.prices(active);

-- RLS (public read for active prices)
ALTER TABLE public.prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active prices"
    ON public.prices FOR SELECT
    TO authenticated, anon
    USING (active = true);

-- =====================================================
-- TABLE: subscriptions
-- User subscriptions synced from Stripe
-- =====================================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
    -- nanoid primary key
    id TEXT PRIMARY KEY DEFAULT nanoid('sub_'),

    -- Stripe reference
    stripe_subscription_id TEXT UNIQUE NOT NULL,

    -- Customer reference (links to customers.user_id)
    customer_id UUID NOT NULL REFERENCES public.customers(user_id) ON DELETE CASCADE,

    -- Price reference
    price_id TEXT REFERENCES public.prices(id),

    -- Subscription status
    status TEXT NOT NULL CHECK (status IN (
        'active', 'canceled', 'incomplete', 'incomplete_expired',
        'past_due', 'paused', 'trialing', 'unpaid'
    )),

    -- Quantity (for per-seat billing)
    quantity INTEGER DEFAULT 1,

    -- Billing cycle
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,

    -- Cancellation
    cancel_at TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT false,
    canceled_at TIMESTAMPTZ,

    -- Trial
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT subscriptions_id_format CHECK (id ~ '^sub_[0-9a-zA-Z]{17}$'),
    CONSTRAINT subscriptions_stripe_id_format CHECK (stripe_subscription_id ~ '^sub_')
);

COMMENT ON TABLE public.subscriptions IS 'Stripe subscriptions synced via webhooks';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_id ON public.subscriptions(stripe_subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_customer_id ON public.subscriptions(customer_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_period_end ON public.subscriptions(current_period_end);

-- RLS (users see own subscriptions)
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own subscriptions"
    ON public.subscriptions FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = customer_id);

-- =====================================================
-- TABLE: stripe_events
-- Idempotency tracking for webhook events
-- =====================================================

CREATE TABLE IF NOT EXISTS public.stripe_events (
    -- Event ID from Stripe (primary key)
    stripe_event_id TEXT PRIMARY KEY,

    -- Event details
    type TEXT NOT NULL,
    api_version TEXT,

    -- Processing timestamp
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT stripe_events_id_format CHECK (stripe_event_id ~ '^evt_')
);

COMMENT ON TABLE public.stripe_events IS 'Processed webhook events for idempotency';

-- Index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_stripe_events_processed_at ON public.stripe_events(processed_at);

-- No RLS needed - accessed via service role only

-- =====================================================
-- TABLE: invoices (Optional)
-- Synced from Stripe invoices
-- =====================================================

CREATE TABLE IF NOT EXISTS public.invoices (
    -- nanoid primary key
    id TEXT PRIMARY KEY DEFAULT nanoid('inv_'),

    -- Stripe reference
    stripe_invoice_id TEXT UNIQUE NOT NULL,

    -- Customer reference
    customer_id UUID NOT NULL REFERENCES public.customers(user_id) ON DELETE CASCADE,

    -- Subscription reference (optional)
    subscription_id TEXT REFERENCES public.subscriptions(id),

    -- Invoice status
    status TEXT NOT NULL CHECK (status IN (
        'draft', 'open', 'paid', 'void', 'uncollectible'
    )),

    -- Amounts (in cents)
    amount_due INTEGER NOT NULL,
    amount_paid INTEGER DEFAULT 0,
    amount_remaining INTEGER,

    -- Currency
    currency TEXT NOT NULL DEFAULT 'usd',

    -- URLs
    hosted_invoice_url TEXT,
    invoice_pdf TEXT,

    -- Dates
    period_start TIMESTAMPTZ,
    period_end TIMESTAMPTZ,
    due_date TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,

    -- Metadata
    metadata JSONB DEFAULT '{}',

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT invoices_id_format CHECK (id ~ '^inv_[0-9a-zA-Z]{17}$'),
    CONSTRAINT invoices_stripe_id_format CHECK (stripe_invoice_id ~ '^in_')
);

COMMENT ON TABLE public.invoices IS 'Stripe invoices synced via webhooks';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_invoices_stripe_id ON public.invoices(stripe_invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoices_customer_id ON public.invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON public.invoices(status);

-- RLS
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own invoices"
    ON public.invoices FOR SELECT
    TO authenticated
    USING ((SELECT auth.uid()) = customer_id);

-- =====================================================
-- TRIGGERS: Auto-update updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER prices_updated_at
    BEFORE UPDATE ON public.prices
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER subscriptions_updated_at
    BEFORE UPDATE ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER invoices_updated_at
    BEFORE UPDATE ON public.invoices
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- =====================================================
-- FUNCTION: Cleanup old stripe_events
-- Run periodically to prevent table bloat
-- =====================================================

CREATE OR REPLACE FUNCTION public.cleanup_stripe_events(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.stripe_events
    WHERE processed_at < NOW() - (days_to_keep || ' days')::INTERVAL;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

COMMENT ON FUNCTION public.cleanup_stripe_events IS 'Removes old webhook events. Call periodically via cron.';
```

## TypeScript Types

```typescript
// types/stripe-database.ts

// Prefixed ID types
export type CustomerPublicId = `cus_${string}`
export type ProductId = `prd_${string}`
export type PriceId = `pri_${string}`
export type SubscriptionId = `sub_${string}`
export type InvoiceId = `inv_${string}`

// Subscription status
export type SubscriptionStatus =
  | 'active'
  | 'canceled'
  | 'incomplete'
  | 'incomplete_expired'
  | 'past_due'
  | 'paused'
  | 'trialing'
  | 'unpaid'

// Invoice status
export type InvoiceStatus =
  | 'draft'
  | 'open'
  | 'paid'
  | 'void'
  | 'uncollectible'

// Database row types
export interface Customer {
  user_id: string
  public_id: CustomerPublicId
  stripe_customer_id: string
  email: string | null
  name: string | null
  default_payment_method: string | null
  metadata: Record<string, unknown>
  created_at: string
  updated_at: string
}

export interface Product {
  id: ProductId
  stripe_product_id: string
  name: string
  description: string | null
  active: boolean
  images: string[]
  features: string[]
  metadata: Record<string, unknown>
  created_at: string
  updated_at: string
}

export interface Price {
  id: PriceId
  stripe_price_id: string
  product_id: ProductId
  active: boolean
  currency: string
  unit_amount: number | null
  type: 'one_time' | 'recurring'
  interval: 'day' | 'week' | 'month' | 'year' | null
  interval_count: number
  usage_type: 'licensed' | 'metered' | null
  billing_scheme: 'per_unit' | 'tiered' | null
  tiers: unknown | null
  tiers_mode: 'graduated' | 'volume' | null
  trial_period_days: number | null
  metadata: Record<string, unknown>
  created_at: string
  updated_at: string
}

export interface Subscription {
  id: SubscriptionId
  stripe_subscription_id: string
  customer_id: string
  price_id: PriceId | null
  status: SubscriptionStatus
  quantity: number
  current_period_start: string | null
  current_period_end: string | null
  cancel_at: string | null
  cancel_at_period_end: boolean
  canceled_at: string | null
  trial_start: string | null
  trial_end: string | null
  metadata: Record<string, unknown>
  created_at: string
  updated_at: string
}

export interface Invoice {
  id: InvoiceId
  stripe_invoice_id: string
  customer_id: string
  subscription_id: SubscriptionId | null
  status: InvoiceStatus
  amount_due: number
  amount_paid: number
  amount_remaining: number | null
  currency: string
  hosted_invoice_url: string | null
  invoice_pdf: string | null
  period_start: string | null
  period_end: string | null
  due_date: string | null
  paid_at: string | null
  metadata: Record<string, unknown>
  created_at: string
  updated_at: string
}

// Joined types for queries
export interface SubscriptionWithPrice extends Subscription {
  price: Price & {
    product: Product
  }
}

export interface CustomerWithSubscription extends Customer {
  subscriptions: SubscriptionWithPrice[]
}

// Validation helpers
export function isValidCustomerPublicId(id: string): id is CustomerPublicId {
  return /^cus_[0-9a-zA-Z]{17}$/.test(id)
}

export function isValidProductId(id: string): id is ProductId {
  return /^prd_[0-9a-zA-Z]{17}$/.test(id)
}

export function isValidPriceId(id: string): id is PriceId {
  return /^pri_[0-9a-zA-Z]{17}$/.test(id)
}

export function isValidSubscriptionId(id: string): id is SubscriptionId {
  return /^sub_[0-9a-zA-Z]{17}$/.test(id)
}

export function isActiveSubscription(status: SubscriptionStatus): boolean {
  return ['active', 'trialing'].includes(status)
}
```

## Common Queries

### Get User's Active Subscription

```typescript
async function getActiveSubscription(userId: string) {
  const { data, error } = await supabase
    .from('subscriptions')
    .select(`
      *,
      price:prices(
        *,
        product:products(*)
      )
    `)
    .eq('customer_id', userId)
    .in('status', ['active', 'trialing'])
    .single()

  return { data, error }
}
```

### Get All Products with Prices

```typescript
async function getProductsWithPrices() {
  const { data, error } = await supabase
    .from('products')
    .select(`
      *,
      prices(*)
    `)
    .eq('active', true)
    .eq('prices.active', true)
    .order('metadata->order', { ascending: true })

  return { data, error }
}
```

### Check Subscription Status

```typescript
async function hasActiveSubscription(userId: string): Promise<boolean> {
  const { data } = await supabase
    .from('subscriptions')
    .select('id')
    .eq('customer_id', userId)
    .in('status', ['active', 'trialing'])
    .single()

  return !!data
}
```

### Get Customer by Stripe ID

```typescript
async function getCustomerByStripeId(stripeCustomerId: string) {
  const { data, error } = await supabase
    .from('customers')
    .select('*')
    .eq('stripe_customer_id', stripeCustomerId)
    .single()

  return { data, error }
}
```

### Get Invoices

```typescript
async function getUserInvoices(userId: string, limit = 10) {
  const { data, error } = await supabase
    .from('invoices')
    .select('*')
    .eq('customer_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit)

  return { data, error }
}
```

## Edge Function Webhook Handler

```typescript
// supabase/functions/stripe-webhook/index.ts
import { createClient } from 'npm:@supabase/supabase-js@2'
import Stripe from 'npm:stripe@17'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2024-12-18.acacia',
})

const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200 })
  }

  const signature = req.headers.get('stripe-signature')

  if (!signature) {
    return new Response('Missing signature', { status: 400 })
  }

  try {
    const body = await req.text()
    const event = stripe.webhooks.constructEvent(body, signature, webhookSecret)

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SECRET_KEY')!
    )

    // Idempotency check
    const { data: existing } = await supabase
      .from('stripe_events')
      .select('stripe_event_id')
      .eq('stripe_event_id', event.id)
      .single()

    if (existing) {
      return new Response(
        JSON.stringify({ received: true, cached: true }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Process event
    await processEvent(supabase, event)

    // Record event
    await supabase.from('stripe_events').insert({
      stripe_event_id: event.id,
      type: event.type,
      api_version: event.api_version,
    })

    return new Response(
      JSON.stringify({ received: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (err: any) {
    console.error('Webhook error:', err.message)
    return new Response(`Webhook Error: ${err.message}`, { status: 400 })
  }
})

async function processEvent(supabase: any, event: Stripe.Event) {
  switch (event.type) {
    case 'customer.created':
    case 'customer.updated':
      await syncCustomer(supabase, event.data.object as Stripe.Customer)
      break

    case 'product.created':
    case 'product.updated':
      await syncProduct(supabase, event.data.object as Stripe.Product)
      break

    case 'price.created':
    case 'price.updated':
      await syncPrice(supabase, event.data.object as Stripe.Price)
      break

    case 'customer.subscription.created':
    case 'customer.subscription.updated':
      await syncSubscription(supabase, event.data.object as Stripe.Subscription)
      break

    case 'customer.subscription.deleted':
      await deleteSubscription(supabase, event.data.object as Stripe.Subscription)
      break

    case 'invoice.paid':
    case 'invoice.payment_failed':
      await syncInvoice(supabase, event.data.object as Stripe.Invoice)
      break
  }
}

async function syncCustomer(supabase: any, customer: Stripe.Customer) {
  const userId = customer.metadata?.user_id
  if (!userId) return

  await supabase.from('customers').upsert({
    user_id: userId,
    stripe_customer_id: customer.id,
    email: customer.email,
    name: customer.name,
    metadata: customer.metadata,
  })
}

async function syncProduct(supabase: any, product: Stripe.Product) {
  await supabase.from('products').upsert(
    {
      stripe_product_id: product.id,
      name: product.name,
      description: product.description,
      active: product.active,
      images: product.images,
      metadata: product.metadata,
      features: product.features?.map(f => f.name) || [],
    },
    { onConflict: 'stripe_product_id' }
  )
}

async function syncPrice(supabase: any, price: Stripe.Price) {
  const productId = typeof price.product === 'string'
    ? price.product
    : price.product.id

  const { data: product } = await supabase
    .from('products')
    .select('id')
    .eq('stripe_product_id', productId)
    .single()

  if (!product) return

  await supabase.from('prices').upsert(
    {
      stripe_price_id: price.id,
      product_id: product.id,
      active: price.active,
      currency: price.currency,
      unit_amount: price.unit_amount,
      type: price.type,
      interval: price.recurring?.interval,
      interval_count: price.recurring?.interval_count || 1,
      usage_type: price.recurring?.usage_type,
      billing_scheme: price.billing_scheme,
      trial_period_days: price.recurring?.trial_period_days,
      metadata: price.metadata,
    },
    { onConflict: 'stripe_price_id' }
  )
}

async function syncSubscription(supabase: any, subscription: Stripe.Subscription) {
  const customerId = typeof subscription.customer === 'string'
    ? subscription.customer
    : subscription.customer.id

  const { data: customer } = await supabase
    .from('customers')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .single()

  if (!customer) return

  const item = subscription.items.data[0]
  const stripePriceId = typeof item.price === 'string' ? item.price : item.price.id

  const { data: price } = await supabase
    .from('prices')
    .select('id')
    .eq('stripe_price_id', stripePriceId)
    .single()

  await supabase.from('subscriptions').upsert(
    {
      stripe_subscription_id: subscription.id,
      customer_id: customer.user_id,
      price_id: price?.id,
      status: subscription.status,
      quantity: item.quantity || 1,
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      cancel_at: subscription.cancel_at
        ? new Date(subscription.cancel_at * 1000).toISOString()
        : null,
      cancel_at_period_end: subscription.cancel_at_period_end,
      canceled_at: subscription.canceled_at
        ? new Date(subscription.canceled_at * 1000).toISOString()
        : null,
      trial_start: subscription.trial_start
        ? new Date(subscription.trial_start * 1000).toISOString()
        : null,
      trial_end: subscription.trial_end
        ? new Date(subscription.trial_end * 1000).toISOString()
        : null,
    },
    { onConflict: 'stripe_subscription_id' }
  )
}

async function deleteSubscription(supabase: any, subscription: Stripe.Subscription) {
  await supabase
    .from('subscriptions')
    .update({
      status: 'canceled',
      canceled_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)
}

async function syncInvoice(supabase: any, invoice: Stripe.Invoice) {
  const customerId = typeof invoice.customer === 'string'
    ? invoice.customer
    : invoice.customer?.id

  if (!customerId) return

  const { data: customer } = await supabase
    .from('customers')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .single()

  if (!customer) return

  let subscriptionId = null
  if (invoice.subscription) {
    const stripeSubId = typeof invoice.subscription === 'string'
      ? invoice.subscription
      : invoice.subscription.id

    const { data: sub } = await supabase
      .from('subscriptions')
      .select('id')
      .eq('stripe_subscription_id', stripeSubId)
      .single()

    subscriptionId = sub?.id
  }

  await supabase.from('invoices').upsert(
    {
      stripe_invoice_id: invoice.id,
      customer_id: customer.user_id,
      subscription_id: subscriptionId,
      status: invoice.status,
      amount_due: invoice.amount_due,
      amount_paid: invoice.amount_paid,
      amount_remaining: invoice.amount_remaining,
      currency: invoice.currency,
      hosted_invoice_url: invoice.hosted_invoice_url,
      invoice_pdf: invoice.invoice_pdf,
      period_start: invoice.period_start
        ? new Date(invoice.period_start * 1000).toISOString()
        : null,
      period_end: invoice.period_end
        ? new Date(invoice.period_end * 1000).toISOString()
        : null,
      paid_at: invoice.status === 'paid'
        ? new Date().toISOString()
        : null,
    },
    { onConflict: 'stripe_invoice_id' }
  )
}
```

## Checklist

- [ ] nanoid function exists (from postgres-nanoid skill)
- [ ] Migration applied with all tables
- [ ] RLS policies active
- [ ] Indexes created
- [ ] TypeScript types generated/created
- [ ] Webhook handler deployed
- [ ] Products/prices synced from Stripe
- [ ] Customer creation on signup
- [ ] Subscription sync verified

## References

- https://supabase.com/blog/stripe-sync-engine-integration - Stripe Sync Engine announcement
- https://supabase.com/docs/guides/integrations/stripe - Official Stripe integration docs
- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/functions
- https://supabase.com/partners/integrations/supabase_wrapper_stripe - Stripe Foreign Data Wrapper
- https://supabase.github.io/wrappers/stripe/ - Stripe Wrapper documentation
