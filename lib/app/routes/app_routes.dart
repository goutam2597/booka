import 'package:get/get.dart';
import 'package:bookapp_customer/features/auth/ui/screens/login_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/splash_screen.dart';
import 'package:bookapp_customer/features/common/ui/screens/bottom_nav_bar.dart';
import 'package:bookapp_customer/features/home/ui/screens/notifications_screen.dart';
import 'package:bookapp_customer/features/vendors/ui/screens/vendors_screen.dart';
import 'package:bookapp_customer/features/vendors/ui/screens/vendor_details_screen.dart';
import 'package:bookapp_customer/features/services/ui/screens/services_details_screen.dart';
import 'package:bookapp_customer/features/account/ui/screens/edit_profile_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/password_change.dart';
import 'package:bookapp_customer/features/account/ui/screens/dashboard_screen.dart';
import 'package:bookapp_customer/features/wishlist/ui/screens/wishlist_screen.dart';
import 'package:bookapp_customer/features/account/ui/screens/settings_screen.dart';
import 'package:bookapp_customer/features/home/ui/screens/all_categories_screen.dart';
import 'package:bookapp_customer/features/home/ui/screens/category_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/signup_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/email_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/otp_screen.dart';
import 'package:bookapp_customer/features/auth/ui/screens/reset_success_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/custom_stepper_screen.dart';
import 'package:bookapp_customer/features/appointments/ui/screens/appointments_screen.dart';
import 'package:bookapp_customer/features/appointments/ui/screens/appointment_details_screen.dart';
import 'package:bookapp_customer/features/home/ui/screens/notification_details.dart';
import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/checkout_webview.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/authorize_net_token_webview.dart';
import 'package:bookapp_customer/features/auth/ui/screens/sign_up_sccess.dart';
import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String bottomNav = '/home';
  static const String login = '/login';
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notification-details';
  static const String vendors = '/vendors';
  static const String serviceDetails = '/service-details';
  static const String vendorDetails = '/vendor-details';
  static const String editProfile = '/edit-profile';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';
  static const String dashboard = '/dashboard';
  static const String wishlist = '/wishlist';
  static const String settings = '/settings';
  static const String allCategories = '/all-categories';
  static const String category = '/category';
  static const String signup = '/signup';
  static const String email = '/email';
  static const String otp = '/otp';
  static const String customStepper = '/booking-stepper';
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointment-details';
  static const String checkoutWebView = '/checkout-webview';
  static const String authorizeNetWebView = '/authorize-net-webview';
  static const String signupSuccess = '/signup-success';
}

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.bottomNav,
      page: () {
        final args = Get.arguments;
        int initialIndex = 0;
        if (args is int) initialIndex = args;
        if (args is Map && args['initialIndex'] is int) {
          initialIndex = args['initialIndex'] as int;
        }
        return BottomNavBar(initialIndex: initialIndex);
      },
    ),
    GetPage(
      name: AppRoutes.login,
      page: () {
        // Allow passing either a simple bool or a map {redirectToHome: bool}
        final args = Get.arguments;
        bool redirect = false;
        if (args is bool) {
          redirect = args;
        } else if (args is Map) {
          final val = args['redirectToHome'];
            if (val is bool) redirect = val;
        }
        return LoginScreen(redirectToHome: redirect);
      },
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.notificationDetails,
      page: () {
        final arg = Get.arguments;
        if (arg is NotificationModel) {
          return NotificationDetails(notification: arg);
        }
        // Fallback empty model to avoid crash if misused
        return NotificationDetails(
          notification: NotificationModel(
            title: '',
            body: '',
            type: 'general',
            timestamp: DateTime.now(),
            data: null,
            isRead: true,
          ),
        );
      },
    ),
    GetPage(name: AppRoutes.vendors, page: () => const VendorsScreen()),
    GetPage(
      name: AppRoutes.vendorDetails,
      page: () {
        final username = (Get.arguments as String?) ?? '';
        return VendorDetailsScreen(username: username);
      },
    ),
    GetPage(
      name: AppRoutes.serviceDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final String slug = (args?['slug'] as String?) ?? '';
        final int id = (args?['id'] as int?) ?? 0;
        return ServiceDetailsScreen(serviceSlug: slug, serviceId: id);
      },
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () {
        final userId = (Get.arguments as int?) ?? 0;
        return DashboardScreen(userId: userId);
      },
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () {
        final userId = (Get.arguments as int?) ?? 0;
        return WishlistScreen(userId: userId);
      },
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.allCategories,
      page: () {
        final cats = (Get.arguments as List<dynamic>? ?? const <dynamic>[])
            .cast<CategoryModel>();
        return AllCategoriesScreen(categories: cats);
      },
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => CategoryScreen(category: Get.arguments as CategoryModel),
    ),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.email, page: () => const EmailScreen()),
    GetPage(
      name: AppRoutes.otp,
      page: () => OtpScreen(email: Get.arguments as String),
    ),
    GetPage(
      name: AppRoutes.resetSuccess,
      page: () => const ResetSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.customStepper,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final service = args?['selectedService'] as ServicesModel;
        return CustomStepperScreen(selectedService: service);
      },
    ),
    GetPage(
      name: AppRoutes.appointments,
      page: () => const AppointmentsScreen(),
    ),
    GetPage(
      name: AppRoutes.appointmentDetails,
      page: () {
        final id = (Get.arguments as int?) ?? 0;
        return AppointmentDetailsScreen(appointmentId: id);
      },
    ),
    GetPage(
      name: AppRoutes.checkoutWebView,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final url = args?['url'] as String? ?? '';
        final finishScheme = args?['finishScheme'] as String? ?? '';
        final title = args?['title'] as String? ?? 'Checkout';
        return CheckoutWebView(
          url: url,
          finishScheme: finishScheme,
          title: title,
        );
      },
    ),
    GetPage(
      name: AppRoutes.authorizeNetWebView,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return AuthorizeNetWebView(
          token: args?['token'] as String?,
          checkoutUrl: args?['checkoutUrl'] as String?,
          successScheme:
              (args?['successScheme'] as String?) ?? 'myapp://anet-success',
          cancelScheme:
              (args?['cancelScheme'] as String?) ?? 'myapp://anet-cancel',
          title: (args?['title'] as String?) ?? 'Authorize.Net',
        );
      },
    ),
    GetPage(name: AppRoutes.signupSuccess, page: () => const SignUpSuccess()),
  ];
}
