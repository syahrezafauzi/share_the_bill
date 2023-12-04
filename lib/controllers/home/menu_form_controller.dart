import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MenuFormController extends GetxController{
  final formatCurrency = NumberFormat.simpleCurrency(locale: "id-ID");
  String toCurrency(double number) =>
      number == null ? "" : formatCurrency.format(number);

}