import 'package:get/get.dart';
import 'package:share_the_bill/controllers/home/menu_form_controller.dart';

class MenuFomBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => MenuFormController());
  }

}