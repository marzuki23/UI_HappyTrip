import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/itinerary/bindings/itinerary_binding.dart';
import '../modules/itinerary/views/itinerary_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
// import '../modules/profile/views/profile_view.dart';
import '../modules/recommendation/views/recommendation_view.dart';
import '../modules/recommendation/bindings/recommendation_binding.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
// import '../modules/trip/views/trip_view.dart';

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
      name: '/recommendation',
      page: () => const RecommendationView(),
      binding: RecommendationBinding(),
    ),
    GetPage(
      name: _Paths.ITINERARY,
      page: () => const ItineraryView(),
      binding: ItineraryBinding(),
    ),
  ];
}
