# Next.js Integration Reference

Complete guide to integrating Stripe with Next.js App Router, Server Actions, and proxy-based subscription checks.

## Project Setup

### 1. Install Dependencies

```bash
npm install stripe @stripe/stripe-js
```

### 2. Environment Variables

```bash
# .env.local
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Your app URL
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 3. Stripe Client Setup

**Server Client:** `lib/stripe/server.ts`

```typescript
import Stripe from 'stripe'

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('STRIPE_SECRET_KEY is not set')
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-12-18.acacia',
  typescript: true,
})
```

**Browser Client:** `lib/stripe/client.ts`

```typescript
import { loadStripe, Stripe } from '@stripe/stripe-js'

let stripePromise: Promise<Stripe | null> | null = null

export function getStripe() {
  if (!stripePromise) {
    stripePromise = loadStripe(
      process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!
    )
  }
  return stripePromise
}
```

## Checkout Flows

### Server Action Checkout

```typescript
// app/actions/stripe.ts
'use server'

import { redirect } from 'next/navigation'
import { stripe } from '@/lib/stripe/server'
import { createClient } from '@/lib/supabase/server'

export async function createCheckoutSession(priceId: string) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Get existing Stripe customer
  const { data: customer } = await supabase
    .from('customers')
    .select('stripe_customer_id')
    .eq('user_id', user.id)
    .single()

  const session = await stripe.checkout.sessions.create({
    customer: customer?.stripe_customer_id,
    customer_email: !customer?.stripe_customer_id ? user.email : undefined,
    mode: 'subscription',
    payment_method_types: ['card'],
    line_items: [
      {
        price: priceId,
        quantity: 1,
      },
    ],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
    metadata: {
      user_id: user.id,
    },
    subscription_data: {
      metadata: {
        user_id: user.id,
      },
    },
  })

  if (!session.url) {
    throw new Error('Failed to create checkout session')
  }

  redirect(session.url)
}
```

### Pricing Page Component

```typescript
// app/pricing/page.tsx
import { createCheckoutSession } from '@/app/actions/stripe'
import { stripe } from '@/lib/stripe/server'

async function getPrices() {
  const prices = await stripe.prices.list({
    active: true,
    expand: ['data.product'],
    type: 'recurring',
  })

  return prices.data.sort((a, b) => (a.unit_amount || 0) - (b.unit_amount || 0))
}

export default async function PricingPage() {
  const prices = await getPrices()

  return (
    <div className="grid gap-6 md:grid-cols-3">
      {prices.map((price) => {
        const product = price.product as Stripe.Product

        return (
          <div key={price.id} className="border rounded-lg p-6">
            <h2 className="text-xl font-bold">{product.name}</h2>
            <p className="text-gray-600">{product.description}</p>

            <div className="my-4">
              <span className="text-3xl font-bold">
                ${(price.unit_amount || 0) / 100}
              </span>
              <span className="text-gray-500">
                /{price.recurring?.interval}
              </span>
            </div>

            <form action={createCheckoutSession.bind(null, price.id)}>
              <button
                type="submit"
                className="w-full bg-blue-600 text-white py-2 rounded-lg"
              >
                Subscribe
              </button>
            </form>
          </div>
        )
      })}
    </div>
  )
}
```

### Success Page

```typescript
// app/checkout/success/page.tsx
import { stripe } from '@/lib/stripe/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'

interface Props {
  searchParams: Promise<{ session_id?: string }>
}

export default async function CheckoutSuccessPage({ searchParams }: Props) {
  const { session_id } = await searchParams

  if (!session_id) {
    redirect('/pricing')
  }

  const session = await stripe.checkout.sessions.retrieve(session_id)

  if (session.payment_status !== 'paid') {
    redirect('/pricing')
  }

  return (
    <div className="text-center py-12">
      <h1 className="text-2xl font-bold text-green-600">
        Payment Successful!
      </h1>
      <p className="mt-4 text-gray-600">
        Thank you for subscribing. Your account has been upgraded.
      </p>
      <Link
        href="/dashboard"
        className="mt-6 inline-block bg-blue-600 text-white px-6 py-2 rounded-lg"
      >
        Go to Dashboard
      </Link>
    </div>
  )
}
```

## Customer Portal

### Server Action

```typescript
// app/actions/stripe.ts
'use server'

import { redirect } from 'next/navigation'
import { stripe } from '@/lib/stripe/server'
import { createClient } from '@/lib/supabase/server'

export async function createPortalSession() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  const { data: customer } = await supabase
    .from('customers')
    .select('stripe_customer_id')
    .eq('user_id', user.id)
    .single()

  if (!customer?.stripe_customer_id) {
    redirect('/pricing')
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: customer.stripe_customer_id,
    return_url: `${process.env.NEXT_PUBLIC_APP_URL}/settings/billing`,
  })

  redirect(session.url)
}
```

### Billing Settings Component

```typescript
// app/settings/billing/page.tsx
import { createPortalSession } from '@/app/actions/stripe'
import { createClient } from '@/lib/supabase/server'

async function getSubscription(userId: string) {
  const supabase = await createClient()

  const { data } = await supabase
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

  return data
}

export default async function BillingPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    return <div>Please log in</div>
  }

  const subscription = await getSubscription(user.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Billing</h1>

      {subscription ? (
        <div className="border rounded-lg p-6">
          <h2 className="font-semibold">Current Plan</h2>
          <p className="text-xl mt-2">
            {subscription.price?.product?.name}
          </p>
          <p className="text-gray-600">
            ${(subscription.price?.unit_amount || 0) / 100}/
            {subscription.price?.interval}
          </p>
          <p className="text-sm text-gray-500 mt-2">
            {subscription.status === 'trialing'
              ? `Trial ends ${new Date(subscription.trial_end!).toLocaleDateString()}`
              : `Renews ${new Date(subscription.current_period_end).toLocaleDateString()}`
            }
          </p>

          <form action={createPortalSession} className="mt-4">
            <button
              type="submit"
              className="bg-gray-800 text-white px-4 py-2 rounded"
            >
              Manage Subscription
            </button>
          </form>
        </div>
      ) : (
        <div className="border rounded-lg p-6">
          <p>No active subscription</p>
          <a
            href="/pricing"
            className="mt-4 inline-block bg-blue-600 text-white px-4 py-2 rounded"
          >
            View Plans
          </a>
        </div>
      )}
    </div>
  )
}
```

## Subscription Check in Proxy

```typescript
// proxy.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function proxy(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  // Public routes - no auth needed
  const publicRoutes = ['/', '/pricing', '/login', '/signup', '/api/webhooks']
  const isPublicRoute = publicRoutes.some(route =>
    request.nextUrl.pathname.startsWith(route)
  )

  if (isPublicRoute) {
    return supabaseResponse
  }

  // Auth required routes
  if (!user) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Premium routes - subscription required
  const premiumRoutes = ['/dashboard', '/api/v1']
  const isPremiumRoute = premiumRoutes.some(route =>
    request.nextUrl.pathname.startsWith(route)
  )

  if (isPremiumRoute) {
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('status, current_period_end')
      .eq('customer_id', user.id)
      .in('status', ['active', 'trialing'])
      .single()

    if (!subscription) {
      return NextResponse.redirect(new URL('/pricing', request.url))
    }

    // Optional: Check if subscription is expired
    const periodEnd = new Date(subscription.current_period_end)
    if (periodEnd < new Date()) {
      return NextResponse.redirect(new URL('/pricing?expired=true', request.url))
    }
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

## Webhook Handler

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers'
import { stripe } from '@/lib/stripe/server'
import { createClient } from '@supabase/supabase-js'
import type Stripe from 'stripe'

// Use admin client for webhook (bypasses RLS)
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SECRET_KEY!
)

export async function POST(req: Request) {
  const body = await req.text()
  const headersList = await headers()
  const signature = headersList.get('stripe-signature')

  if (!signature) {
    return new Response('Missing stripe-signature', { status: 400 })
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
    return Response.json({ received: true, cached: true })
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutComplete(event.data.object)
        break

      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionChange(event.data.object)
        break

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object)
        break

      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object)
        break

      default:
        console.log(`Unhandled event: ${event.type}`)
    }

    // Record event
    await supabaseAdmin
      .from('stripe_events')
      .insert({
        stripe_event_id: event.id,
        type: event.type,
      })

    return Response.json({ received: true })

  } catch (err) {
    console.error('Webhook handler error:', err)
    return new Response('Webhook handler failed', { status: 500 })
  }
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const userId = session.metadata?.user_id
  if (!userId) return

  // Ensure customer record exists
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
}

async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const customerId = typeof subscription.customer === 'string'
    ? subscription.customer
    : subscription.customer.id

  const { data: customer } = await supabaseAdmin
    .from('customers')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .single()

  if (!customer) {
    console.error('Customer not found:', customerId)
    return
  }

  const item = subscription.items.data[0]
  const priceId = typeof item.price === 'string' ? item.price : item.price.id

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
      cancel_at_period_end: subscription.cancel_at_period_end,
      canceled_at: subscription.canceled_at
        ? new Date(subscription.canceled_at * 1000).toISOString()
        : null,
      trial_end: subscription.trial_end
        ? new Date(subscription.trial_end * 1000).toISOString()
        : null,
    }, {
      onConflict: 'stripe_subscription_id',
    })
}

async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  await supabaseAdmin
    .from('subscriptions')
    .update({
      status: 'canceled',
      canceled_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  if (!invoice.subscription) return

  const subscriptionId = typeof invoice.subscription === 'string'
    ? invoice.subscription
    : invoice.subscription.id

  await supabaseAdmin
    .from('subscriptions')
    .update({ status: 'past_due' })
    .eq('stripe_subscription_id', subscriptionId)

  // TODO: Send email notification to customer
}
```

## Stripe Elements (Custom UI)

### Payment Form Component

```typescript
// components/PaymentForm.tsx
'use client'

import { useState } from 'react'
import {
  PaymentElement,
  Elements,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js'
import { getStripe } from '@/lib/stripe/client'

function CheckoutForm() {
  const stripe = useStripe()
  const elements = useElements()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!stripe || !elements) return

    setLoading(true)
    setError(null)

    const { error: submitError } = await elements.submit()
    if (submitError) {
      setError(submitError.message || 'An error occurred')
      setLoading(false)
      return
    }

    const { error: confirmError } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/checkout/success`,
      },
    })

    if (confirmError) {
      setError(confirmError.message || 'Payment failed')
    }

    setLoading(false)
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <PaymentElement />

      {error && (
        <div className="text-red-500 text-sm">{error}</div>
      )}

      <button
        type="submit"
        disabled={!stripe || loading}
        className="w-full bg-blue-600 text-white py-2 rounded disabled:opacity-50"
      >
        {loading ? 'Processing...' : 'Pay'}
      </button>
    </form>
  )
}

interface PaymentFormProps {
  clientSecret: string
}

export function PaymentForm({ clientSecret }: PaymentFormProps) {
  return (
    <Elements
      stripe={getStripe()}
      options={{
        clientSecret,
        appearance: {
          theme: 'stripe',
        },
      }}
    >
      <CheckoutForm />
    </Elements>
  )
}
```

### Create Payment Intent Server Action

```typescript
// app/actions/stripe.ts
'use server'

import { stripe } from '@/lib/stripe/server'
import { createClient } from '@/lib/supabase/server'

export async function createPaymentIntent(priceId: string) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    throw new Error('Not authenticated')
  }

  // Get price details
  const price = await stripe.prices.retrieve(priceId)

  if (!price.unit_amount) {
    throw new Error('Invalid price')
  }

  // Get or create customer
  let { data: customer } = await supabase
    .from('customers')
    .select('stripe_customer_id')
    .eq('user_id', user.id)
    .single()

  if (!customer?.stripe_customer_id) {
    const stripeCustomer = await stripe.customers.create({
      email: user.email,
      metadata: { user_id: user.id },
    })

    await supabase.from('customers').insert({
      user_id: user.id,
      stripe_customer_id: stripeCustomer.id,
      email: user.email,
    })

    customer = { stripe_customer_id: stripeCustomer.id }
  }

  const paymentIntent = await stripe.paymentIntents.create({
    amount: price.unit_amount,
    currency: price.currency,
    customer: customer.stripe_customer_id,
    automatic_payment_methods: { enabled: true },
    metadata: {
      user_id: user.id,
      price_id: priceId,
    },
  })

  return { clientSecret: paymentIntent.client_secret }
}
```

## Embedded Pricing Table

Stripe provides a no-code pricing table you can embed.

```typescript
// components/StripePricingTable.tsx
'use client'

import { useEffect } from 'react'

declare global {
  namespace JSX {
    interface IntrinsicElements {
      'stripe-pricing-table': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & {
          'pricing-table-id': string
          'publishable-key': string
          'customer-session-client-secret'?: string
        },
        HTMLElement
      >
    }
  }
}

interface Props {
  pricingTableId: string
  customerSessionClientSecret?: string
}

export function StripePricingTable({
  pricingTableId,
  customerSessionClientSecret,
}: Props) {
  useEffect(() => {
    const script = document.createElement('script')
    script.src = 'https://js.stripe.com/v3/pricing-table.js'
    script.async = true
    document.body.appendChild(script)

    return () => {
      document.body.removeChild(script)
    }
  }, [])

  return (
    <stripe-pricing-table
      pricing-table-id={pricingTableId}
      publishable-key={process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!}
      customer-session-client-secret={customerSessionClientSecret}
    />
  )
}
```

## Helper Hooks

### useSubscription Hook

```typescript
// hooks/useSubscription.ts
'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'

interface Subscription {
  id: string
  status: string
  current_period_end: string
  price: {
    unit_amount: number
    interval: string
    product: {
      name: string
    }
  }
}

export function useSubscription() {
  const [subscription, setSubscription] = useState<Subscription | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const supabase = createClient()

    async function fetchSubscription() {
      const { data: { user } } = await supabase.auth.getUser()

      if (!user) {
        setLoading(false)
        return
      }

      const { data } = await supabase
        .from('subscriptions')
        .select(`
          *,
          price:prices(
            unit_amount,
            interval,
            product:products(name)
          )
        `)
        .eq('customer_id', user.id)
        .in('status', ['active', 'trialing'])
        .single()

      setSubscription(data)
      setLoading(false)
    }

    fetchSubscription()

    // Subscribe to changes
    const channel = supabase
      .channel('subscription-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'subscriptions',
        },
        () => fetchSubscription()
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return {
    subscription,
    loading,
    isActive: subscription?.status === 'active',
    isTrialing: subscription?.status === 'trialing',
    hasSubscription: !!subscription,
  }
}
```

## Checklist

- [ ] Stripe dependencies installed
- [ ] Environment variables configured
- [ ] Server and client Stripe instances created
- [ ] Checkout flow implemented with Server Actions
- [ ] Customer Portal integration
- [ ] Webhook handler with idempotency
- [ ] Subscription checks in proxy.ts
- [ ] Success/cancel pages created
- [ ] Billing settings page
- [ ] Local webhook testing with Stripe CLI

## References

- https://docs.stripe.com/payments/accept-a-payment?platform=web&ui=elements
- https://docs.stripe.com/checkout/quickstart
- https://docs.stripe.com/customer-management/portal-deep-link
- https://docs.stripe.com/payments/payment-element
