import 'package:get/get.dart';

class AppStrings {
  // Common actions
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String signup = 'Signup';
  static const String loginNow = 'Login Now';
  static const String makePayment = 'Make Payment';
  static const String filter = 'Filter';
  static const String total = 'Total';

  // Languages
  static const String english = 'English';
  static const String arabic = 'Arabic';

  // Auth / account
  static const String confirmLogout = 'Confirm Logout';
  static const String logoutPrompt = 'Are you sure you want to logout?';
  static const String logout = 'Logout';
  static const String pleaseVerifyEmail = 'Please verify your email';
  static const String lostYourPassword = 'Lost your password';
  static const String passwordChanged = 'Password Changed!';
  static const String accountCreated = 'Account Created!';

  // Empty / status messages
  static const String noDataFound = 'No Data Found';
  static const String noVendorsFound = 'No vendors found.';
  static const String noNotificationsFound = 'No notifications found!';
  static const String noServicesAvailable = 'No services available';
  static const String noMatchesFound = 'No matches found.';
  static const String stillNoInternet = 'Still no internet connection';
  static const String checkNetworkSettings =
      'Please check your network settings';

  // Payment flow
  static const String serviceBooked = 'Service is Booked';
}

class PaymentStrings {
  static const String checkingCurrency = 'Checking currency';
  static String verifyingAmount = 'Verifying Amount'.tr;
  static  String finalizingBooking = 'Finalizing Booking'.tr;
  static const String verifyTimeout =
      'Verification timed out. Please try again.';
  static const String paymentNotSuccessful = 'Payment is not successful.';

  static String opening(String label) => '${'Opening'.tr} ${label.tr}';
  static String priceUpdatedTo(String amount) => 'Price updated to \$$amount';
}
