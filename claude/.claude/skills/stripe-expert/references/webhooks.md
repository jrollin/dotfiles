# Webhook Handling Reference

Complete guide to secure Stripe webhook handling with idempotency and error recovery.

## Critical Security Rules

### Signature Verification (MANDATORY)

```typescript
// CORRECT: Raw body for signature verification
export async function POST(req: Request) {
  const body = await req.text()  // Raw string
  const signature = req.headers.get('stripe-signature')!

  const event = stripe.webhooks.constructEvent(
    body,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET!
  )
}

// WRONG: This WILL FAIL
export async function POST(req: Request) {
  const body = await req.json()  // DON'T parse first
  // signature verification will fail!
}
```

### Why Raw Body Matters

Stripe creates the signature from the exact bytes sent. If you:
- Parse JSON first
- Modify the body in any way
- Use a body parser middleware

The signature verification will fail.

## Webhook Setup

### 1. Dashboard Configuration

1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. Enter your endpoint URL: `https://your-domain.com/api/webhooks/stripe`
4. Select events to listen for
5. Copy the webhook signing secret (`whsec_...`)

### 2. Recommended Events for Subscriptions

**High Priority (Always Handle):**
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.paid`
- `invoice.payment_failed`

**Medium Priority:**
- `customer.created`
- `customer.updated`
- `product.created`
- `product.updated`
- `price.created`
- `price.updated`

**Optional:**
- `invoice.created`
- `invoice.finalized`
- `payment_intent.succeeded`
- `payment_intent.payment_failed`

## Idempotency Pattern

Stripe may send the same event multiple times. Always implement idempotency.

### Database Table

```sql
CREATE TABLE IF NOT EXISTS public.stripe_events (
    stripe_event_id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    api_version TEXT,
    processed_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.stripe_events IS 'Processed webhook events for idempotency';

-- Auto-cleanup old events (run periodically)
-- DELETE FROM stripe_events WHERE processed_at < NOW() - INTERVAL '30 days';
```

### Idempotency Check

```typescript
async function handleWebhook(event: Stripe.Event) {
  // Check if already processed
  const { data: existing } = await supabase
    .from('stripe_events')
    .select('stripe_event_id')
    .eq('stripe_event_id', event.id)
    .single()

  if (existing) {
    console.log(`Event ${event.id} already processed, skipping`)
    return { success: true, cached: true }
  }

  // Process event
  await processEvent(event)

  // Mark as processed
  await supabase
    .from('stripe_events')
    .insert({
      stripe_event_id: event.id,
      type: event.type,
      api_version: event.api_version,
    })

  return { success: true }
}
```

## Complete Webhook Handler

### Next.js App Router

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers'
import Stripe from 'stripe'
import { createClient } from '@supabase/supabase-js'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
})

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SECRET_KEY!
)

export async function POST(req: Request) {
  const body = await req.text()
  const headersList = await headers()
  const signature = headersList.get('stripe-signature')

  if (!signature) {
    return new Response('Missing stripe-signature header', { status: 400 })
  }

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err: any) {
    console.error('Webhook signature verification failed:', err.message)
    return new Response(`Webhook Error: ${err.message}`, { status: 400 })
  }

  // Idempotency check
  const { data: existing } = await supabaseAdmin
    .from('stripe_events')
    .select('stripe_event_id')
    .eq('stripe_event_id', event.id)
    .single()

  if (existing) {
    return new Response(JSON.stringify({ received: true, cached: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }

  try {
    switch (event.type) {
      // Customer events
      case 'customer.created':
        await handleCustomerCreated(event.data.object as Stripe.Customer)
        break
      case 'customer.updated':
        await handleCustomerUpdated(event.data.object as Stripe.Customer)
        break

      // Checkout events
      case 'checkout.session.completed':
        await handleCheckoutComplete(event.data.object as Stripe.Checkout.Session)
        break

      // Subscription events
      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object as Stripe.Subscription)
        break
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription)
        break
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription)
        break

      // Invoice events
      case 'invoice.paid':
        await handleInvoicePaid(event.data.object as Stripe.Invoice)
        break
      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice)
        break

      // Product/Price sync
      case 'product.created':
      case 'product.updated':
        await handleProductSync(event.data.object as Stripe.Product)
        break
      case 'price.created':
      case 'price.updated':
        await handlePriceSync(event.data.object as Stripe.Price)
        break

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    // Record processed event
    await supabaseAdmin
      .from('stripe_events')
      .insert({
        stripe_event_id: event.id,
        type: event.type,
        api_version: event.api_version,
      })

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    })

  } catch (err) {
    console.error('Error processing webhook:', err)
    // Return 500 so Stripe will retry
    return new Response('Webhook handler failed', { status: 500 })
  }
}

// Handler implementations
async function handleCustomerCreated(customer: Stripe.Customer) {
  const userId = customer.metadata?.user_id

  if (!userId) {
    console.warn('Customer created without user_id metadata:', customer.id)
    return
  }

  await supabaseAdmin
    .from('customers')
    .upsert({
      user_id: userId,
      stripe_customer_id: customer.id,
      email: customer.email,
      name: customer.name,
    })
}

async function handleCustomerUpdated(customer: Stripe.Customer) {
  await supabaseAdmin
    .from('customers')
    .update({
      email: customer.email,
      name: customer.name,
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_customer_id', customer.id)
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.user_id

  if (!userId) {
    console.warn('Checkout completed without user_id:', session.id)
    return
  }

  // Ensure customer is linked
  if (session.customer) {
    const customerId = typeof session.customer === 'string'
      ? session.customer
      : session.customer.id

    await supabaseAdmin
      .from('customers')
      .upsert({
        user_id: userId,
        stripe_customer_id: customerId,
        email: session.customer_email,
      })
  }

  // Subscription is handled by subscription.created event
  console.log('Checkout completed for user:', userId)
}

async function handleSubscriptionCreated(subscription: Stripe.Subscription) {
  const customerId = typeof subscription.customer === 'string'
    ? subscription.customer
    : subscription.customer.id

  // Get local customer
  const { data: customer } = await supabaseAdmin
    .from('customers')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .single()

  if (!customer) {
    console.error('Customer not found for subscription:', customerId)
    return
  }

  const item = subscription.items.data[0]
  const priceId = typeof item.price === 'string' ? item.price : item.price.id

  // Get local price
  const { data: price } = await supabaseAdmin
    .from('prices')
    .select('id')
    .eq('stripe_price_id', priceId)
    .single()

  await supabaseAdmin
    .from('subscriptions')
    .upsert({
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
      trial_start: subscription.trial_start
        ? new Date(subscription.trial_start * 1000).toISOString()
        : null,
      trial_end: subscription.trial_end
        ? new Date(subscription.trial_end * 1000).toISOString()
        : null,
    })
}

async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  // Same logic as created - upsert handles both
  await handleSubscriptionCreated(subscription)
}

async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  await supabaseAdmin
    .from('subscriptions')
    .update({
      status: 'canceled',
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)
}

async function handleInvoicePaid(invoice: Stripe.Invoice) {
  if (!invoice.subscription) return

  const subscriptionId = typeof invoice.subscription === 'string'
    ? invoice.subscription
    : invoice.subscription.id

  // Update subscription status to active (in case it was past_due)
  await supabaseAdmin
    .from('subscriptions')
    .update({
      status: 'active',
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscriptionId)
}

async function handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
  if (!invoice.subscription) return

  const subscriptionId = typeof invoice.subscription === 'string'
    ? invoice.subscription
    : invoice.subscription.id

  // Update subscription status
  await supabaseAdmin
    .from('subscriptions')
    .update({
      status: 'past_due',
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscriptionId)

  // TODO: Send notification to customer
  console.log('Payment failed for subscription:', subscriptionId)
}

async function handleProductSync(product: Stripe.Product) {
  await supabaseAdmin
    .from('products')
    .upsert({
      stripe_product_id: product.id,
      name: product.name,
      description: product.description,
      active: product.active,
      images: product.images,
      metadata: product.metadata,
    }, {
      onConflict: 'stripe_product_id'
    })
}

async function handlePriceSync(price: Stripe.Price) {
  const productId = typeof price.product === 'string'
    ? price.product
    : price.product.id

  // Get local product
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('id')
    .eq('stripe_product_id', productId)
    .single()

  if (!product) {
    console.warn('Product not found for price:', productId)
    return
  }

  await supabaseAdmin
    .from('prices')
    .upsert({
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
    }, {
      onConflict: 'stripe_price_id'
    })
}
```

### Supabase Edge Function

```typescript
// supabase/functions/stripe-webhook/index.ts
import { createClient } from 'npm:@supabase/supabase-js@2'
import Stripe from 'npm:stripe@17'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2024-12-18.acacia',
})

const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!

Deno.serve(async (req: Request) => {
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
      return new Response(JSON.stringify({ received: true, cached: true }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Handle event (implement handlers as needed)
    console.log('Processing event:', event.type)

    // Record event
    await supabase
      .from('stripe_events')
      .insert({
        stripe_event_id: event.id,
        type: event.type,
        api_version: event.api_version,
      })

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    })

  } catch (err: any) {
    console.error('Webhook error:', err.message)
    return new Response(`Webhook Error: ${err.message}`, { status: 400 })
  }
})
```

## Error Handling

### Retry Behavior

Stripe will retry failed webhooks:
- Immediately, then after 1 hour, 2 hours, 4 hours, etc.
- Up to 72 hours total
- Returns 2xx = success, anything else = retry

### Error Response Codes

| Code | Meaning | Stripe Action |
|------|---------|---------------|
| 200-299 | Success | Mark delivered |
| 400 | Bad request | No retry (signature failure) |
| 500 | Server error | Retry |
| Timeout | No response | Retry |

### Best Practices

```typescript
export async function POST(req: Request) {
  try {
    // Signature verification
    const event = stripe.webhooks.constructEvent(...)

    // Quick acknowledgment - return 200 fast
    // For long operations, queue for background processing

    // Process synchronously for simple operations
    await processEvent(event)

    return new Response('OK', { status: 200 })

  } catch (err) {
    if (err instanceof Stripe.errors.StripeSignatureVerificationError) {
      // Don't retry signature failures
      return new Response('Invalid signature', { status: 400 })
    }

    // Return 500 to trigger retry
    console.error('Webhook error:', err)
    return new Response('Internal error', { status: 500 })
  }
}
```

## Local Development

### Using Stripe CLI

```bash
# Install
brew install stripe/stripe-cli/stripe

# Login (one-time)
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# In another terminal, trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_failed
```

### Test Webhook Secrets

When using `stripe listen`, you'll get a temporary webhook secret:
```
Ready! Your webhook signing secret is whsec_xxxxx
```

Use this secret in your `.env.local` for local testing.

## Event Types Reference

### Checkout Events

| Event | Payload | Use Case |
|-------|---------|----------|
| `checkout.session.completed` | Session | Provision access |
| `checkout.session.expired` | Session | Cleanup pending |
| `checkout.session.async_payment_succeeded` | Session | Delayed payment success |
| `checkout.session.async_payment_failed` | Session | Delayed payment failure |

### Subscription Events

| Event | Payload | Use Case |
|-------|---------|----------|
| `customer.subscription.created` | Subscription | New subscription |
| `customer.subscription.updated` | Subscription | Plan change, renewal |
| `customer.subscription.deleted` | Subscription | Cancellation complete |
| `customer.subscription.paused` | Subscription | Subscription paused |
| `customer.subscription.resumed` | Subscription | Subscription resumed |
| `customer.subscription.trial_will_end` | Subscription | 3 days before trial ends |

### Invoice Events

| Event | Payload | Use Case |
|-------|---------|----------|
| `invoice.created` | Invoice | New invoice created |
| `invoice.finalized` | Invoice | Invoice ready for payment |
| `invoice.paid` | Invoice | Payment successful |
| `invoice.payment_failed` | Invoice | Payment failed |
| `invoice.payment_action_required` | Invoice | 3D Secure required |
| `invoice.upcoming` | Invoice | Upcoming invoice preview |

### Customer Events

| Event | Payload | Use Case |
|-------|---------|----------|
| `customer.created` | Customer | New customer |
| `customer.updated` | Customer | Customer details changed |
| `customer.deleted` | Customer | Customer deleted |

## Checklist

- [ ] Webhook endpoint URL configured in Stripe Dashboard
- [ ] Events selected in Dashboard
- [ ] Webhook secret stored in environment variables
- [ ] Signature verification using raw body
- [ ] Idempotency table created
- [ ] Idempotency check before processing
- [ ] Event recorded after successful processing
- [ ] Error handling returns appropriate status codes
- [ ] Local testing with Stripe CLI working

## References

- https://docs.stripe.com/webhooks
- https://docs.stripe.com/webhooks/signatures
- https://docs.stripe.com/cli/listen
