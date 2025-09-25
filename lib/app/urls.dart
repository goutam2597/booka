/// Centralized API endpoints for the application
class Urls {
  // Base API URL
  static const String _baseUrl = 'https://masud.kreativdev.com/bookapp';
  static const String _apiBaseUrl = '$_baseUrl/api';

  // Base for PHP helper endpoints used by payment gateways
  static const String pgwBaseUrl = '$_baseUrl/pgw';

  static const String authorizeNetHostedPaymentUrl =
      'https://accept.authorize.net/payment/payment';

  static const String mapTilerUrlTemplate =
      'https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key={key}';
  static const String openStreetMapUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ----------------------------
  // Authentication Endpoints
  // ----------------------------
  static const String loginUrl = '$_apiBaseUrl/customer/login/submit';
  static const String forgetPassUrl = '$_apiBaseUrl/customer/forget-password';
  static const String resetPassUrl = '$_apiBaseUrl/customer/reset-password';
  static const String signUpUrl = '$_apiBaseUrl/customer/signup/submit';
  static const String changePasswordUrl =
      '$_apiBaseUrl/customer/update-password';
  static const String updateProfileUrl = '$_apiBaseUrl/customer/update-profile';
  static const String editProfileUrl = '$_apiBaseUrl/customer/edit-profile';

  // ----------------------------
  // Services Endpoints
  // ----------------------------
  // Home endpoint (single source for home screen data)
  static const String homeUrl = _apiBaseUrl;

  static const String servicesUrl = '$_apiBaseUrl/services';
  static String servicesDetailsUrl(String slug, int id) =>
      '$_apiBaseUrl/services/details/$slug/$id';
  static String removeWishlistUrl(int serviceId) =>
      '$_apiBaseUrl/services/remove/wishlist/$serviceId';
  static String getStaffContentUrl(int serviceId) =>
      '$_apiBaseUrl/services/get-staff-content/$serviceId';
  static String dateTimeUrl(int vendorId, int serviceId) =>
      '$_apiBaseUrl/services/check-date-time/$vendorId?service_id=$serviceId';
  static String staffHoursUrl(
    String dayName,
    int staffId,
    String bookingDate,
    int vendorId,
    int serviceId,
  ) =>
      '$_apiBaseUrl/services/show-staff-hour/?dayName=$dayName&staff_id=$staffId&bookingDate=$bookingDate&vendor_id=$vendorId&serviceId=$serviceId';
  static String submitBookingFormUrl(
    String email,
    String address,
    String name,
    String phone,
  ) =>
      '$_apiBaseUrl/services/billing-form/submit?name=$name&phone=$phone&email=$email&address=$address';

  // ----------------------------
  // Vendor Endpoints
  // ----------------------------
  static const String vendorsUrl = '$_apiBaseUrl/vendors';
  static String vendorDetailsUrl(String vendorUsername) =>
      '$_apiBaseUrl/vendor/$vendorUsername';

  // ----------------------------
  // Appointment Endpoints
  // ----------------------------
  static const String appointmentsUrl = '$_apiBaseUrl/customer/appointment';
  static String appointmentsDetailsUrl(int id) =>
      '$_apiBaseUrl/customer/appointment/details/$id';

  // ----------------------------
  // Dashboard & Wishlist Endpoints
  // ----------------------------
  static const String dashboardUrl = '$_apiBaseUrl/customer/dashboard';
  static const String wishlistUrl = '$_apiBaseUrl/customer/wishlist';
  static String addToWishlistUrl(int serviceId) =>
      '$_apiBaseUrl/services/addto/wishlist/$serviceId';
  static String removeFromWishlistUrl(int serviceId) =>
      '$_apiBaseUrl/services/remove/wishlist/$serviceId';

  // ----------------------------
  // Orders Endpoints
  // ----------------------------
  static const String ordersUrl = '$_apiBaseUrl/customer/order';
  static String ordersDetailsUrl(int orderId) =>
      '$_apiBaseUrl/customer/order/details/$orderId';

  static String storeReviewUrl(int serviceId) =>
      '$_apiBaseUrl/services/store-review/$serviceId';

  static String get serviceInquiryUrl =>
      '$_apiBaseUrl/services/send-inquiry-message';

  static String get vendorInquiryUrl => '$_apiBaseUrl/vendor/contact';

  // ----------------------------
  // Checkout & Payments Endpoints
  // ----------------------------
  // Finalize booking/payment on backend
  static const String paymentProcessUrl = '$_apiBaseUrl/payment-process';

  // Verify payment amount with backend (note: path uses 'verfiy-payment' per backend API)
  static String verifyPaymentUrl({
    required String amount,
    required String gateway,
    required int vendorId,
    required String bookingDate,
  }) =>
      '$_apiBaseUrl/verfiy-payment?amount=$amount&gateway=$gateway&vendor_id=$vendorId&booking_date=$bookingDate';

  // ----------------------------
  // Localization Endpoints
  // ----------------------------
  static const String getLangBase = '$_apiBaseUrl/get-lang';
  static String getLangUrl(String languageCode) => '$getLangBase/$languageCode';
  // Basic app info (includes languages list, base currency, etc.)
  static const String getBasicUrl = '$_apiBaseUrl/get-basic';

  // Custom pages (Terms, Privacy, etc.)
  static const String customPagesUrl = '$_apiBaseUrl/custom-page';
}
