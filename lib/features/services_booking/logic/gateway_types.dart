enum GatewayType {
  googlePay,
  paypal,
  stripe,
  flutterWave,
  payStack,
  mollie,
  xendit,
  toyyibpay,
  razorpay,
  authorize_net,
  midtrans,
  myfatoorah,
  mercadoPago,
  monnify,
  nowPayments,
  phonePe,
}

String gatewayLabel(GatewayType g) {
  switch (g) {
    case GatewayType.googlePay:
      return 'Google Pay';
    case GatewayType.paypal:
      return 'PayPal';
    case GatewayType.stripe:
      return 'Stripe';
    case GatewayType.flutterWave:
      return 'FlutterWave';
    case GatewayType.payStack:
      return 'PayStack';
    case GatewayType.mollie:
      return 'Mollie';
    case GatewayType.xendit:
      return 'Xendit';
    case GatewayType.toyyibpay:
      return 'Toyyibpay';
    case GatewayType.mercadoPago:
      return 'Mercado Pago';
    case GatewayType.monnify:
      return 'Monnify';
    case GatewayType.razorpay:
      return 'Razorpay';
    case GatewayType.authorize_net:
      return 'Authorize.Net';
    case GatewayType.midtrans:
      return 'MidTrans';
    case GatewayType.myfatoorah:
      return 'MyFatoorah';
    case GatewayType.nowPayments:
      return 'NOWPayments';
    case GatewayType.phonePe:
      return 'PhonePe';
  }
}

/// Backend keyword/slug used by verfiy-payment endpoint for each gateway
String gatewayKeyword(GatewayType g) {
  switch (g) {
    case GatewayType.googlePay:
      return 'googlepay';
    case GatewayType.paypal:
      return 'paypal';
    case GatewayType.stripe:
      return 'stripe';
    case GatewayType.flutterWave:
      return 'flutterwave';
    case GatewayType.payStack:
      return 'paystack';
    case GatewayType.mollie:
      return 'mollie';
    case GatewayType.xendit:
      return 'xendit';
    case GatewayType.toyyibpay:
      return 'toyyibpay';
    case GatewayType.razorpay:
      return 'razorpay';
    case GatewayType.authorize_net:
      return 'authorize.net';
    case GatewayType.midtrans:
      return 'midtrans';
    case GatewayType.myfatoorah:
      return 'myfatoorah';
    case GatewayType.mercadoPago:
      return 'mercadopago';
    case GatewayType.monnify:
      return 'monnify';
    case GatewayType.nowPayments:
      return 'nowpayments';
    case GatewayType.phonePe:
      return 'phonepe';
  }
}

/// Default supported currencies per gateway; can be overridden per-instance
/// from server-side config.
const Map<GatewayType, Set<String>> kDefaultSupportedCurrencies = {
  GatewayType.googlePay: {'USD', 'EUR', 'GBP', 'INR'},
  GatewayType.paypal: {'USD', 'EUR', 'GBP'},
  GatewayType.stripe: {'USD', 'EUR', 'GBP', 'AUD', 'CAD'},
  GatewayType.flutterWave: {'NGN', 'GHS', 'KES', 'USD'},
  GatewayType.payStack: {'NGN'},
  GatewayType.mollie: {
    'EUR',
    'USD',
    'GBP',
    'AED',
    'SAR',
    'QAR',
    'OMR',
    'BHD',
    'AUD',
    'CAD',
  },
  GatewayType.xendit: {'IDR', 'PHP'},
  GatewayType.toyyibpay: {'MYR'},
  GatewayType.razorpay: {'INR', 'USD'},
  GatewayType.authorize_net: {'USD'},
  GatewayType.midtrans: {'IDR'},
  GatewayType.myfatoorah: {
    'KWD',
    'SAR',
    'BHD',
    'AED',
    'QAR',
    'OMR',
    'JOD',
    'USD',
  },
  GatewayType.mercadoPago: {'MXN', 'BRL', 'ARS', 'CLP', 'COP', 'PEN', 'UYU'},
  GatewayType.monnify: {'NGN'},
  GatewayType.nowPayments: {'USD', 'EUR', 'GBP', 'USDT', 'BTC', 'ETH'},
  GatewayType.phonePe: {'INR', 'USD'},
};

/// Map backend keyword (from get-basic online_gateways[].keyword) to GatewayType
GatewayType? gatewayFromApiKeyword(String raw) {
  final k = raw.trim().toLowerCase();
  switch (k) {
    case 'googlepay':
    case 'google_pay':
      // Temporarily disabled
      return null;
    case 'paypal':
      return GatewayType.paypal;
    case 'stripe':
      return GatewayType.stripe;
    case 'flutterwave':
      return GatewayType.flutterWave;
    case 'paystack':
      return GatewayType.payStack;
    case 'mollie':
      return GatewayType.mollie;
    case 'xendit':
      return GatewayType.xendit;
    case 'toyyibpay':
      return GatewayType.toyyibpay;
    case 'razorpay':
      return GatewayType.razorpay;
    case 'authorize.net':
    case 'authorize_net':
      return GatewayType.authorize_net;
    case 'midtrans':
      return GatewayType.midtrans;
    case 'myfatoorah':
      return GatewayType.myfatoorah;
    case 'mercadopago':
      return GatewayType.mercadoPago;
    case 'monnify':
      return GatewayType.monnify;
    case 'nowpayments':
    case 'now_payments':
      return GatewayType.nowPayments;
    case 'phonepe':
      return GatewayType.phonePe;
  }
  return null;
}
