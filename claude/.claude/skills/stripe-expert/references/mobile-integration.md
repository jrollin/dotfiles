# Mobile Integration Reference

Complete guide to integrating Stripe with iOS (Swift), Android (Kotlin), and Flutter.

## Architecture Overview

For mobile apps, use a **server-driven checkout** approach:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Mobile App  │────>│   Backend    │────>│    Stripe    │
│              │<────│  (Next.js)   │<────│              │
└──────────────┘     └──────────────┘     └──────────────┘
     │                     │
     │                     v
     │              ┌──────────────┐
     └─────────────>│   Supabase   │
                    └──────────────┘
```

**Why server-driven:**
- Keeps secret keys secure on server
- Consistent logic across platforms
- Easier to update payment flow
- Better audit trail

## Required Server Endpoints

Create these API endpoints on your backend:

```typescript
// app/api/stripe/create-checkout-session/route.ts
export async function POST(req: Request) {
  const { priceId } = await req.json()
  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.APP_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.APP_URL}/cancel`,
  })
  return Response.json({ url: session.url })
}

// app/api/stripe/create-portal-session/route.ts
export async function POST(req: Request) {
  const { customerId } = await req.json()
  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: `${process.env.APP_URL}/settings`,
  })
  return Response.json({ url: session.url })
}

// app/api/stripe/payment-sheet/route.ts
export async function POST(req: Request) {
  const { customerId, amount, currency } = await req.json()

  const ephemeralKey = await stripe.ephemeralKeys.create(
    { customer: customerId },
    { apiVersion: '2024-12-18.acacia' }
  )

  const paymentIntent = await stripe.paymentIntents.create({
    amount,
    currency,
    customer: customerId,
    automatic_payment_methods: { enabled: true },
  })

  return Response.json({
    paymentIntent: paymentIntent.client_secret,
    ephemeralKey: ephemeralKey.secret,
    customer: customerId,
    publishableKey: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY,
  })
}
```

---

## iOS (Swift)

### Setup

**1. Add Stripe SDK (Swift Package Manager)**

In Xcode: File → Add Package Dependencies

URL: `https://github.com/stripe/stripe-ios`

**2. Configure in AppDelegate/App**

```swift
import Stripe

@main
struct MyApp: App {
    init() {
        StripeAPI.defaultPublishableKey = "pk_test_..."
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Checkout via Web

Redirect to Stripe Checkout in a browser:

```swift
import SafariServices

class CheckoutManager: ObservableObject {
    private let apiURL = "https://your-api.com"

    func startCheckout(priceId: String) async throws {
        // Get checkout URL from your server
        let url = URL(string: "\(apiURL)/api/stripe/create-checkout-session")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(["priceId": priceId])

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CheckoutResponse.self, from: data)

        // Open checkout URL
        await MainActor.run {
            if let checkoutURL = URL(string: response.url) {
                UIApplication.shared.open(checkoutURL)
            }
        }
    }
}

struct CheckoutResponse: Codable {
    let url: String
}
```

### Payment Sheet (Native UI)

For in-app payments with native Stripe UI:

```swift
import Stripe
import StripePaymentSheet

class PaymentManager: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?

    private let apiURL = "https://your-api.com"

    func preparePaymentSheet(amount: Int, currency: String = "usd") async {
        do {
            // Get payment sheet parameters from server
            let url = URL(string: "\(apiURL)/api/stripe/payment-sheet")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode([
                "amount": amount,
                "currency": currency
            ])

            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(PaymentSheetResponse.self, from: data)

            // Configure Payment Sheet
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Your App Name"
            configuration.customer = .init(
                id: response.customer,
                ephemeralKeySecret: response.ephemeralKey
            )
            configuration.allowsDelayedPaymentMethods = true

            await MainActor.run {
                self.paymentSheet = PaymentSheet(
                    paymentIntentClientSecret: response.paymentIntent,
                    configuration: configuration
                )
            }

        } catch {
            print("Failed to prepare payment sheet: \(error)")
        }
    }

    func presentPaymentSheet() {
        guard let paymentSheet else { return }

        paymentSheet.present(from: UIApplication.shared.rootViewController!) { result in
            self.paymentResult = result

            switch result {
            case .completed:
                print("Payment completed!")
            case .canceled:
                print("Payment canceled")
            case .failed(let error):
                print("Payment failed: \(error)")
            }
        }
    }
}

struct PaymentSheetResponse: Codable {
    let paymentIntent: String
    let ephemeralKey: String
    let customer: String
    let publishableKey: String
}

extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
```

### SwiftUI View

```swift
struct PaymentView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Complete your purchase")
                .font(.headline)

            Button(action: {
                Task {
                    isLoading = true
                    await paymentManager.preparePaymentSheet(amount: 2900)
                    isLoading = false
                    paymentManager.presentPaymentSheet()
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Pay $29.00")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .onChange(of: paymentManager.paymentResult) { result in
            if case .completed = result {
                // Navigate to success screen
            }
        }
    }
}
```

### Customer Portal

```swift
func openCustomerPortal() async throws {
    let url = URL(string: "\(apiURL)/api/stripe/create-portal-session")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(PortalResponse.self, from: data)

    if let portalURL = URL(string: response.url) {
        await UIApplication.shared.open(portalURL)
    }
}

struct PortalResponse: Codable {
    let url: String
}
```

---

## Android (Kotlin)

### Setup

**1. Add Stripe SDK (Gradle)**

```kotlin
// app/build.gradle.kts
dependencies {
    implementation("com.stripe:stripe-android:20.+")
}
```

**2. Initialize Stripe**

```kotlin
// Application class
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        PaymentConfiguration.init(
            applicationContext,
            "pk_test_..."
        )
    }
}
```

### Checkout via Web

```kotlin
class CheckoutViewModel : ViewModel() {
    private val apiUrl = "https://your-api.com"

    fun startCheckout(priceId: String, context: Context) {
        viewModelScope.launch {
            try {
                val response = createCheckoutSession(priceId)

                // Open checkout URL in browser
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(response.url))
                context.startActivity(intent)

            } catch (e: Exception) {
                Log.e("Checkout", "Failed to create checkout session", e)
            }
        }
    }

    private suspend fun createCheckoutSession(priceId: String): CheckoutResponse {
        val client = OkHttpClient()
        val json = JSONObject().put("priceId", priceId)

        val request = Request.Builder()
            .url("$apiUrl/api/stripe/create-checkout-session")
            .addHeader("Authorization", "Bearer $authToken")
            .post(json.toString().toRequestBody("application/json".toMediaType()))
            .build()

        return withContext(Dispatchers.IO) {
            client.newCall(request).execute().use { response ->
                val body = response.body?.string() ?: throw Exception("Empty response")
                Gson().fromJson(body, CheckoutResponse::class.java)
            }
        }
    }
}

data class CheckoutResponse(val url: String)
```

### Payment Sheet (Native UI)

```kotlin
class PaymentActivity : AppCompatActivity() {
    private lateinit var paymentSheet: PaymentSheet
    private val apiUrl = "https://your-api.com"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        paymentSheet = PaymentSheet(this, ::onPaymentSheetResult)

        // Prepare and present payment sheet
        lifecycleScope.launch {
            preparePaymentSheet(amount = 2900)
        }
    }

    private suspend fun preparePaymentSheet(amount: Int) {
        try {
            val response = fetchPaymentSheetParams(amount)

            val configuration = PaymentSheet.Configuration(
                merchantDisplayName = "Your App Name",
                customer = PaymentSheet.CustomerConfiguration(
                    id = response.customer,
                    ephemeralKeySecret = response.ephemeralKey
                ),
                allowsDelayedPaymentMethods = true
            )

            paymentSheet.presentWithPaymentIntent(
                response.paymentIntent,
                configuration
            )

        } catch (e: Exception) {
            Log.e("Payment", "Failed to prepare payment sheet", e)
        }
    }

    private suspend fun fetchPaymentSheetParams(amount: Int): PaymentSheetResponse {
        return withContext(Dispatchers.IO) {
            val client = OkHttpClient()
            val json = JSONObject()
                .put("amount", amount)
                .put("currency", "usd")

            val request = Request.Builder()
                .url("$apiUrl/api/stripe/payment-sheet")
                .addHeader("Authorization", "Bearer $authToken")
                .post(json.toString().toRequestBody("application/json".toMediaType()))
                .build()

            client.newCall(request).execute().use { response ->
                val body = response.body?.string() ?: throw Exception("Empty response")
                Gson().fromJson(body, PaymentSheetResponse::class.java)
            }
        }
    }

    private fun onPaymentSheetResult(result: PaymentSheetResult) {
        when (result) {
            is PaymentSheetResult.Completed -> {
                Toast.makeText(this, "Payment successful!", Toast.LENGTH_SHORT).show()
                // Navigate to success screen
            }
            is PaymentSheetResult.Canceled -> {
                Toast.makeText(this, "Payment canceled", Toast.LENGTH_SHORT).show()
            }
            is PaymentSheetResult.Failed -> {
                Toast.makeText(this, "Payment failed: ${result.error.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
}

data class PaymentSheetResponse(
    val paymentIntent: String,
    val ephemeralKey: String,
    val customer: String,
    val publishableKey: String
)
```

### Customer Portal

```kotlin
fun openCustomerPortal(context: Context) {
    lifecycleScope.launch {
        try {
            val client = OkHttpClient()
            val request = Request.Builder()
                .url("$apiUrl/api/stripe/create-portal-session")
                .addHeader("Authorization", "Bearer $authToken")
                .post("{}".toRequestBody("application/json".toMediaType()))
                .build()

            val response = withContext(Dispatchers.IO) {
                client.newCall(request).execute().use { response ->
                    val body = response.body?.string() ?: throw Exception("Empty response")
                    Gson().fromJson(body, PortalResponse::class.java)
                }
            }

            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(response.url))
            context.startActivity(intent)

        } catch (e: Exception) {
            Log.e("Portal", "Failed to open customer portal", e)
        }
    }
}

data class PortalResponse(val url: String)
```

---

## Flutter

### Setup

**1. Add Stripe SDK**

```yaml
# pubspec.yaml
dependencies:
  flutter_stripe: ^11.0.0
  http: ^1.2.0
```

**2. Platform Configuration**

**Android** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 34
    // ...
}
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for card scanning</string>
```

**3. Initialize Stripe**

```dart
// main.dart
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_...';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}
```

### Checkout via Web

```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutService {
  static const apiUrl = 'https://your-api.com';

  Future<void> startCheckout(String priceId, String authToken) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/stripe/create-checkout-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'priceId': priceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final url = Uri.parse(data['url']);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      throw Exception('Failed to create checkout session');
    }
  }
}
```

### Payment Sheet (Native UI)

```dart
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const apiUrl = 'https://your-api.com';

  Future<void> makePayment({
    required int amount,
    required String currency,
    required String authToken,
  }) async {
    try {
      // 1. Fetch payment sheet params from server
      final response = await http.post(
        Uri.parse('$apiUrl/api/stripe/payment-sheet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch payment params');
      }

      final data = jsonDecode(response.body);

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          merchantDisplayName: 'Your App Name',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue,
            ),
          ),
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful!
      print('Payment completed successfully');

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        print('Payment canceled');
      } else {
        print('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

### Flutter Widget

```dart
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      await _paymentService.makePayment(
        amount: 2900, // $29.00
        currency: 'usd',
        authToken: 'your-auth-token',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        Navigator.of(context).pushReplacementNamed('/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Complete your purchase',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Pay \$29.00'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Customer Portal

```dart
Future<void> openCustomerPortal(String authToken) async {
  final response = await http.post(
    Uri.parse('$apiUrl/api/stripe/create-portal-session'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final url = Uri.parse(data['url']);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  } else {
    throw Exception('Failed to open customer portal');
  }
}
```

---

## Subscription Status Check

All platforms should check subscription status from your backend:

### Server Endpoint

```typescript
// app/api/subscription/status/route.ts
export async function GET(req: Request) {
  const userId = await getUserIdFromAuth(req)

  const { data: subscription } = await supabase
    .from('subscriptions')
    .select('status, current_period_end, price:prices(product:products(name))')
    .eq('customer_id', userId)
    .in('status', ['active', 'trialing'])
    .single()

  if (!subscription) {
    return Response.json({ hasActiveSubscription: false })
  }

  return Response.json({
    hasActiveSubscription: true,
    status: subscription.status,
    expiresAt: subscription.current_period_end,
    planName: subscription.price?.product?.name,
  })
}
```

### iOS Check

```swift
func checkSubscriptionStatus() async throws -> SubscriptionStatus {
    let url = URL(string: "\(apiURL)/api/subscription/status")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONDecoder().decode(SubscriptionStatus.self, from: data)
}

struct SubscriptionStatus: Codable {
    let hasActiveSubscription: Bool
    let status: String?
    let expiresAt: String?
    let planName: String?
}
```

### Android Check

```kotlin
suspend fun checkSubscriptionStatus(): SubscriptionStatus {
    val client = OkHttpClient()
    val request = Request.Builder()
        .url("$apiUrl/api/subscription/status")
        .addHeader("Authorization", "Bearer $authToken")
        .get()
        .build()

    return withContext(Dispatchers.IO) {
        client.newCall(request).execute().use { response ->
            val body = response.body?.string() ?: throw Exception("Empty response")
            Gson().fromJson(body, SubscriptionStatus::class.java)
        }
    }
}

data class SubscriptionStatus(
    val hasActiveSubscription: Boolean,
    val status: String?,
    val expiresAt: String?,
    val planName: String?
)
```

### Flutter Check

```dart
Future<SubscriptionStatus> checkSubscriptionStatus(String authToken) async {
  final response = await http.get(
    Uri.parse('$apiUrl/api/subscription/status'),
    headers: {'Authorization': 'Bearer $authToken'},
  );

  if (response.statusCode == 200) {
    return SubscriptionStatus.fromJson(jsonDecode(response.body));
  }
  throw Exception('Failed to check subscription status');
}

class SubscriptionStatus {
  final bool hasActiveSubscription;
  final String? status;
  final String? expiresAt;
  final String? planName;

  SubscriptionStatus({
    required this.hasActiveSubscription,
    this.status,
    this.expiresAt,
    this.planName,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasActiveSubscription: json['hasActiveSubscription'],
      status: json['status'],
      expiresAt: json['expiresAt'],
      planName: json['planName'],
    );
  }
}
```

## Deep Links for Success/Cancel

Configure deep links to handle checkout completion:

### iOS Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

### Android AndroidManifest.xml

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yourapp" android:host="checkout" />
</intent-filter>
```

### Checkout URLs

```typescript
// Use app deep links in checkout session
const session = await stripe.checkout.sessions.create({
  // ...
  success_url: 'yourapp://checkout/success?session_id={CHECKOUT_SESSION_ID}',
  cancel_url: 'yourapp://checkout/cancel',
})
```

## Checklist

- [ ] Stripe SDK installed for each platform
- [ ] Publishable key configured
- [ ] Server endpoints created
- [ ] Payment Sheet implementation
- [ ] Checkout via web fallback
- [ ] Customer Portal integration
- [ ] Subscription status checks
- [ ] Deep links configured
- [ ] Error handling implemented

## References

- https://docs.stripe.com/payments/accept-a-payment?platform=ios
- https://docs.stripe.com/payments/accept-a-payment?platform=android
- https://docs.stripe.com/payments/accept-a-payment?platform=flutter
- https://pub.dev/packages/flutter_stripe
