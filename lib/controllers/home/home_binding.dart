import 'package:get/get.dart';
import 'package:share_the_bill/controllers/home/home_controller.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }

}