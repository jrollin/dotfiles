# Subscription Patterns Reference

Complete guide to Stripe subscription billing models: flat rate, per-seat, usage-based, tiered, and hybrid.

## Subscription Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  trialing   │────>│   active    │────>│  canceled   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │
       │                   v
       │            ┌─────────────┐
       └───────────>│  past_due   │
                    └─────────────┘
                           │
                           v
                    ┌─────────────┐
                    │   unpaid    │
                    └─────────────┘
```

### Status Definitions

| Status | Meaning | Action |
|--------|---------|--------|
| `trialing` | In free trial | Full access |
| `active` | Paying customer | Full access |
| `past_due` | Payment failed, retrying | Limited access (grace period) |
| `unpaid` | All retries exhausted | Revoke access |
| `canceled` | Subscription ended | Revoke access |
| `incomplete` | Initial payment pending | No access |
| `incomplete_expired` | Initial payment failed | No access |
| `paused` | Temporarily paused | No access (or limited) |

## Billing Models

### 1. Flat Rate Subscription

Simple fixed monthly/yearly pricing.

**Use Case:** Most SaaS products, single tier pricing

```typescript
// Create a flat rate price
const price = await stripe.prices.create({
  product: 'prod_xxx',
  unit_amount: 2900, // $29.00
  currency: 'usd',
  recurring: {
    interval: 'month',
  },
})

// Create subscription
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: price.id }],
})
```

**Checkout Session:**
```typescript
const session = await stripe.checkout.sessions.create({
  customer: customerId,
  mode: 'subscription',
  line_items: [
    {
      price: 'price_xxx', // Your flat rate price ID
      quantity: 1,
    },
  ],
  success_url: `${baseUrl}/success?session_id={CHECKOUT_SESSION_ID}`,
  cancel_url: `${baseUrl}/pricing`,
})
```

### 2. Per-Seat Pricing

Charge per user/member/seat.

**Use Case:** Team plans, enterprise software

```typescript
// Create per-seat price
const price = await stripe.prices.create({
  product: 'prod_xxx',
  unit_amount: 1000, // $10 per seat
  currency: 'usd',
  recurring: {
    interval: 'month',
  },
})

// Create subscription with initial seats
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [
    {
      price: price.id,
      quantity: 5, // 5 seats = $50/month
    },
  ],
})

// Update seat count
await stripe.subscriptions.update(subscription.id, {
  items: [
    {
      id: subscription.items.data[0].id,
      quantity: 10, // Now 10 seats = $100/month
    },
  ],
  proration_behavior: 'create_prorations', // Charge/credit difference
})
```

**Helper Function:**
```typescript
async function updateSeatCount(subscriptionId: string, newSeatCount: number) {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)

  return stripe.subscriptions.update(subscriptionId, {
    items: [
      {
        id: subscription.items.data[0].id,
        quantity: newSeatCount,
      },
    ],
    proration_behavior: 'create_prorations',
  })
}
```

### 3. Usage-Based Billing (Metered)

Charge based on consumption using Stripe Billing Meters.

**Use Case:** API calls, storage, compute time, AI tokens

#### Step 1: Create a Meter

```typescript
// Create meter (usually done once in Dashboard or setup script)
const meter = await stripe.billing.meters.create({
  display_name: 'API Requests',
  event_name: 'api_request', // Use this in meter events
  default_aggregation: {
    formula: 'sum',
  },
})
```

#### Step 2: Create Metered Price

```typescript
const price = await stripe.prices.create({
  product: 'prod_xxx',
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
    meter: meter.id,
  },
  unit_amount: 1, // $0.01 per unit (1 cent)
  // Or use tiers for volume discounts
})
```

#### Step 3: Create Subscription

```typescript
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: price.id }],
})
```

#### Step 4: Report Usage

```typescript
// Report usage via meter events
await stripe.billing.meterEvents.create({
  event_name: 'api_request', // Must match meter's event_name
  payload: {
    stripe_customer_id: customerId,
    value: '100', // Number of API requests
  },
  timestamp: Math.floor(Date.now() / 1000), // Unix timestamp
})
```

**Usage Reporting Helper:**
```typescript
async function reportUsage(
  customerId: string,
  eventName: string,
  value: number
) {
  return stripe.billing.meterEvents.create({
    event_name: eventName,
    payload: {
      stripe_customer_id: customerId,
      value: value.toString(),
    },
  })
}

// Usage
await reportUsage('cus_xxx', 'api_request', 150)
await reportUsage('cus_xxx', 'tokens_used', 10000)
```

### 4. Tiered Pricing

Volume discounts based on usage.

**Use Case:** "First 100 free, then $0.10 each"

#### Graduated Tiers (Cumulative)

Each tier applies to its range only.

```typescript
const price = await stripe.prices.create({
  product: 'prod_xxx',
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
  },
  billing_scheme: 'tiered',
  tiers_mode: 'graduated',
  tiers: [
    { up_to: 100, unit_amount: 0 },        // First 100 free
    { up_to: 1000, unit_amount: 10 },      // 101-1000: $0.10 each
    { up_to: 10000, unit_amount: 5 },      // 1001-10000: $0.05 each
    { up_to: 'inf', unit_amount: 2 },      // 10001+: $0.02 each
  ],
})
```

**Example calculation for 5000 units:**
- 0-100: $0 (100 × $0)
- 101-1000: $90 (900 × $0.10)
- 1001-5000: $200 (4000 × $0.05)
- Total: $290

#### Volume Tiers (All-or-Nothing)

Entire usage charged at the tier rate reached.

```typescript
const price = await stripe.prices.create({
  product: 'prod_xxx',
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
  },
  billing_scheme: 'tiered',
  tiers_mode: 'volume',
  tiers: [
    { up_to: 100, unit_amount: 100 },      // 1-100: $1.00 each
    { up_to: 1000, unit_amount: 80 },      // 101-1000: $0.80 each (all units)
    { up_to: 'inf', unit_amount: 50 },     // 1001+: $0.50 each (all units)
  ],
})
```

**Example calculation for 5000 units:**
- All 5000 at $0.50: $2,500

### 5. Hybrid Billing

Combine base subscription + usage.

**Use Case:** "Base $49/month + $0.01 per API call"

```typescript
// Create base price
const basePrice = await stripe.prices.create({
  product: 'prod_xxx',
  unit_amount: 4900, // $49 base
  currency: 'usd',
  recurring: { interval: 'month' },
})

// Create metered price
const usagePrice = await stripe.prices.create({
  product: 'prod_xxx',
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
    meter: meterId,
  },
  unit_amount: 1, // $0.01 per unit
})

// Create subscription with both prices
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [
    { price: basePrice.id },
    { price: usagePrice.id },
  ],
})
```

## Trial Periods

### Free Trial

```typescript
// Option 1: On the price
const price = await stripe.prices.create({
  product: 'prod_xxx',
  unit_amount: 2900,
  currency: 'usd',
  recurring: {
    interval: 'month',
    trial_period_days: 14,
  },
})

// Option 2: On the subscription
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: priceId }],
  trial_period_days: 14,
})

// Option 3: Specific trial end date
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: priceId }],
  trial_end: Math.floor(Date.now() / 1000) + (14 * 24 * 60 * 60),
})
```

### Trial Without Payment Method

```typescript
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: priceId }],
  trial_period_days: 14,
  payment_behavior: 'default_incomplete', // Don't require payment method
  trial_settings: {
    end_behavior: {
      missing_payment_method: 'pause', // Pause when trial ends without card
    },
  },
})
```

### Checkout with Trial

```typescript
const session = await stripe.checkout.sessions.create({
  customer: customerId,
  mode: 'subscription',
  line_items: [{ price: priceId, quantity: 1 }],
  subscription_data: {
    trial_period_days: 14,
  },
  success_url: `${baseUrl}/success`,
  cancel_url: `${baseUrl}/pricing`,
})
```

## Plan Changes (Upgrades/Downgrades)

### Immediate Change with Proration

```typescript
async function changePlan(subscriptionId: string, newPriceId: string) {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)

  return stripe.subscriptions.update(subscriptionId, {
    items: [
      {
        id: subscription.items.data[0].id,
        price: newPriceId,
      },
    ],
    proration_behavior: 'create_prorations', // Charge/credit immediately
  })
}
```

### Change at Period End

```typescript
async function schedulePlanChange(subscriptionId: string, newPriceId: string) {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)

  // Schedule the change
  await stripe.subscriptionSchedules.create({
    from_subscription: subscriptionId,
    phases: [
      {
        items: [{ price: newPriceId, quantity: 1 }],
        start_date: subscription.current_period_end,
      },
    ],
  })
}
```

### Proration Options

```typescript
await stripe.subscriptions.update(subscriptionId, {
  items: [{ id: itemId, price: newPriceId }],
  proration_behavior: 'create_prorations',  // Default: charge/credit difference
  // Or: 'none' - no proration
  // Or: 'always_invoice' - create invoice immediately
})
```

## Cancellation

### Cancel at Period End

```typescript
// User keeps access until period ends
const subscription = await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true,
})

// Undo cancellation
const subscription = await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: false,
})
```

### Cancel Immediately

```typescript
// Access revoked immediately
const subscription = await stripe.subscriptions.cancel(subscriptionId)
```

### Cancel with Refund

```typescript
// Cancel and refund prorated amount
const subscription = await stripe.subscriptions.cancel(subscriptionId, {
  prorate: true,
  invoice_now: true, // Generate final invoice with credit
})
```

## Pause and Resume

### Pause Collection

```typescript
// Pause payment collection (keep subscription active)
await stripe.subscriptions.update(subscriptionId, {
  pause_collection: {
    behavior: 'void', // Don't create invoices
    // Or: 'keep_as_draft' - create draft invoices
    // Or: 'mark_uncollectible' - create uncollectible invoices
  },
})
```

### Resume Collection

```typescript
await stripe.subscriptions.update(subscriptionId, {
  pause_collection: null, // Resume
})
```

## Multiple Products

### Add-Ons

```typescript
// Add an add-on to existing subscription
await stripe.subscriptionItems.create({
  subscription: subscriptionId,
  price: addonPriceId,
  quantity: 1,
})

// Remove add-on
await stripe.subscriptionItems.del(subscriptionItemId)
```

### Multiple Subscription Items

```typescript
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [
    { price: 'price_base', quantity: 1 },      // Base plan
    { price: 'price_seats', quantity: 5 },     // 5 seats
    { price: 'price_storage', quantity: 100 }, // 100GB storage
  ],
})
```

## Invoicing

### Preview Upcoming Invoice

```typescript
const upcomingInvoice = await stripe.invoices.retrieveUpcoming({
  customer: customerId,
})

console.log('Next invoice amount:', upcomingInvoice.amount_due / 100)
console.log('Next billing date:', new Date(upcomingInvoice.period_end * 1000))
```

### Preview Plan Change

```typescript
const preview = await stripe.invoices.retrieveUpcoming({
  customer: customerId,
  subscription: subscriptionId,
  subscription_items: [
    {
      id: subscription.items.data[0].id,
      price: newPriceId,
    },
  ],
  subscription_proration_behavior: 'create_prorations',
})

console.log('Proration amount:', preview.amount_due / 100)
```

## Helper Functions

### Check Active Subscription

```typescript
async function hasActiveSubscription(customerId: string): Promise<boolean> {
  const subscriptions = await stripe.subscriptions.list({
    customer: customerId,
    status: 'active',
    limit: 1,
  })

  return subscriptions.data.length > 0
}
```

### Get Current Plan

```typescript
async function getCurrentPlan(customerId: string) {
  const subscriptions = await stripe.subscriptions.list({
    customer: customerId,
    status: 'active',
    expand: ['data.items.data.price.product'],
    limit: 1,
  })

  if (subscriptions.data.length === 0) return null

  const subscription = subscriptions.data[0]
  const item = subscription.items.data[0]
  const price = item.price
  const product = price.product as Stripe.Product

  return {
    subscriptionId: subscription.id,
    status: subscription.status,
    productName: product.name,
    priceId: price.id,
    amount: price.unit_amount,
    interval: price.recurring?.interval,
    currentPeriodEnd: new Date(subscription.current_period_end * 1000),
  }
}
```

### Calculate Proration

```typescript
async function calculateProration(
  subscriptionId: string,
  newPriceId: string
): Promise<number> {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)

  const preview = await stripe.invoices.retrieveUpcoming({
    customer: subscription.customer as string,
    subscription: subscriptionId,
    subscription_items: [
      {
        id: subscription.items.data[0].id,
        price: newPriceId,
      },
    ],
    subscription_proration_behavior: 'create_prorations',
  })

  return preview.amount_due / 100
}
```

## Common Patterns

### Feature Gating by Plan

```typescript
// In your database, store plan features
const planFeatures = {
  free: {
    maxProjects: 1,
    maxMembers: 1,
    apiCalls: 100,
    features: ['basic'],
  },
  pro: {
    maxProjects: 10,
    maxMembers: 5,
    apiCalls: 10000,
    features: ['basic', 'advanced', 'api'],
  },
  enterprise: {
    maxProjects: -1, // unlimited
    maxMembers: -1,
    apiCalls: -1,
    features: ['basic', 'advanced', 'api', 'sso', 'audit'],
  },
}

// Check feature access
async function hasFeature(userId: string, feature: string): Promise<boolean> {
  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('price:prices(metadata)')
    .eq('customer_id', userId)
    .in('status', ['active', 'trialing'])
    .single()

  if (!subscription) {
    return planFeatures.free.features.includes(feature)
  }

  const planName = subscription.price?.metadata?.plan || 'free'
  return planFeatures[planName]?.features.includes(feature) || false
}
```

## Checklist

- [ ] Billing model selected (flat/per-seat/usage/tiered/hybrid)
- [ ] Prices created in Stripe Dashboard or via API
- [ ] Checkout flow implemented
- [ ] Webhook handlers for subscription events
- [ ] Subscription status checks in app
- [ ] Plan change (upgrade/downgrade) flow
- [ ] Cancellation flow (immediate vs end of period)
- [ ] Trial period configured (if applicable)
- [ ] Customer portal enabled for self-service
- [ ] Proration behavior configured

## References

- https://docs.stripe.com/billing/subscriptions/overview
- https://docs.stripe.com/billing/subscriptions/usage-based
- https://docs.stripe.com/billing/subscriptions/trials
- https://docs.stripe.com/billing/subscriptions/upgrade-downgrade
