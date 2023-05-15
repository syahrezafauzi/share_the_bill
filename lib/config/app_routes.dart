import 'package:get/get.dart';
import 'package:share_the_bill/controllers/home/home_binding.dart';
import 'package:share_the_bill/views/home/home_page.dart';

class AppRoutes {
  static const String homeRoute = "/home";
  static const String unknownRoute = "/404";

  AppRoutes._();

  static List<GetPage> pages = [
    GetPage(
      name: homeRoute,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];

  // static GetPage get unknownPage => GetPage(
  //       name: unknownRoute,
  //       page: ()=> Error404Page(),
  //       binding: Error404Binding(),
  //     );
}