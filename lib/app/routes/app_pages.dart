import 'package:get/get.dart';

import '../modules/face_login/bindings/face_login_binding.dart';
import '../modules/face_login/views/face_login_view.dart';
import '../modules/face_scan/bindings/face_scan_binding.dart';
import '../modules/face_scan/views/face_scan_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/itinerary/bindings/itinerary_binding.dart';
import '../modules/itinerary/views/itinerary_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/recommendation/bindings/recommendation_binding.dart';
import '../modules/recommendation/views/recommendation_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.TRIP,
      page: () => const HomeView(initialIndex: 1),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const HomeView(initialIndex: 2),
      binding: HomeBinding(),
    ),
    GetPage(
      // Disarankan menggunakan konstanta _Paths agar konsisten
      name: _Paths.RECOMMENDATION,
      page: () => const RecommendationView(),
      binding: RecommendationBinding(),
    ),
    GetPage(
      name: _Paths.ITINERARY,
      page: () => const ItineraryView(),
      binding: ItineraryBinding(),
    ),
    GetPage(
      // Hapus duplikasi '/forgot-password' di bawahnya dan gunakan satu saja yang mengacu ke _Paths
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.FACE_LOGIN,
      page: () => const FaceLoginView(),
      binding: FaceLoginBinding(),
    ),
    GetPage(
      name: _Paths.FACE_SCAN,
      page: () => FaceScanView(),
      binding: FaceScanBinding(),
    ),
  ];
}
