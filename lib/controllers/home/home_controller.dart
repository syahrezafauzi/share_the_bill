import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_the_bill/views/home/menu_form.dart';

class HomeController extends GetxController {
  late Box<Map> box;
  var left = Rx<double>(0);
  var grandTotal = Rx<double?>(452000);
  var title = "Bill Gundaling".obs;
  var menu = <String, double>{
    "Carnivore Pizza": 104348 / 6,
    "Three Cheese Pizza": 95652 / 7,
    "Iced Tiramisu Latte": 86087 / 3,
    "Hot Coffee Latte": 20870,
    "Hot Green Tea Latte": 20870,
    "Hot Tea Cinamon": 15652,
    "Iced Kopi Gula Aren": 23478,
    "Singkong Goreng": 26086 / 3,
  }.obs;
  var ppn = 10.obs;
  var service = RxInt(5);
  var users = <String>[
    "Eric",
    "Denis",
    "Nanda",
    "Reza",
    "Icha",
    "Victor",
    "Williandy",
  ].obs;

  var totals = <double>[].obs;

  var paids = <String, double?>{}.obs;

  var selectedUser = Rx<String?>(null);
  var selectedMenus = Rx<Map<String, List<String>>>({});

  String get getGrandTotal => formatCurrency.format(grandTotal.value);
  final formatCurrency = NumberFormat.simpleCurrency(locale: "id-ID");

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() async {
    box = await Hive.openBox(title.value);
  }

  chooseMenu(String? key, {bool? condition}) {
    if (selectedUser.value != null) {
      if (condition ?? false) {
        var entry = selectedMenus.value.entries
            .where((element) => element.key == selectedUser.value)
            .firstOrNull;
        entry ??=
            MapEntry(selectedUser.value!, List<String>.empty(growable: true));
        entry.value.addIf(!entry.value.any((element) => element == key), key!);
        selectedMenus.value.addEntries([entry]);
      } else {
        if (selectedUser.value != null) {
          var entry = selectedMenus.value.entries
              .where((element) => element.key == selectedUser.value)
              .firstOrNull;
          entry?.value.remove(key);
        }
      }

      selectedMenus.refresh();
    }
  }

  String currency(double? number) =>
      number == null ? "" : formatCurrency.format(number);

  selectUser(String value) {
    if (selectedUser.value == value) {
      selectedUser.value = null;
    } else {
      selectedUser.value = value;
    }
  }

  bool isSelected(String elementAt) {
    var result = selectedUser.value == elementAt;
    return result;
  }

  bool isPaid(String elementAt) {
    return paids.keys.any((element) => element == elementAt);
  }

  paid(String user) {
    if (!isPaid(user)) {
      var calculate = _calculate(user: user);
      var entry =
          paids.entries.where((element) => element.key == user).firstOrNull;
      entry = entry ??= MapEntry<String, double?>(user, calculate.elementAt(2));
      paids.addEntries([entry]);
    }
  }

  bool isChooseMenu(String key) {
    var result = false;
    if (selectedUser.value != null) {
      var entry = selectedMenus.value.entries
          .where((element) => element.key == selectedUser.value)
          .firstOrNull;
      result = entry?.value.any((element) => element == key) ?? false;
    }
    return result;
  }

  List<double?> _calculate({String? user}) {
    var result = <double?>[null, null, null];
    var holder = selectedMenus.value.entries
        .where((element) => user == null ? true : element.key == user);

    for (var items in holder) {
      var item = items.value;
      var total = menu.entries
          .where((element) => item.contains(element.key))
          .map((e) => e.value)
          .sum;
      var _ppn = ppn / 100 * total;
      var gTotal = total + _ppn;
      result[0] = (result[0] ?? 0) + total;
      result[1] = (result[1] ?? 0) + _ppn;
      result[2] = (result[2] ?? 0) + gTotal;
    }

    return result;
  }

  String total(String user) {
    var calculate = _calculate(user: user);
    return currency(calculate.elementAt(0));
  }

  String totalPpn(String user) {
    var calculate = _calculate(user: user);
    return currency(calculate.elementAt(1));
  }

  String sumPpn() {
    var calculate = _calculate();
    return currency(calculate.elementAt(1));
  }

  String totalService(String user) {
    var calculate = _calculateService();
    return currency(calculate);
  }

  double _calculateService() {
    var total = _calculateTotalSum();
    var length = users.length;
    var result = (total * (service / 100)) / length;
    return result;
  }

  String due(String user) {
    double value = _calculateDue(user);
    var result = currency(value);
    return result;
  }

  double _calculateDue(String user) {
    var calculate = _calculate(user: user);
    var value = (calculate.elementAt(2) ?? 0);
    var service = _calculateService();
    return value + service;
  }

  String totalSum() {
    var calculate = _calculate();
    var value = (calculate.elementAt(0) ?? 0);
    return currency(value);
  }

  double _calculateTotalSum() {
    var calculate = _calculate();
    var value = (calculate.elementAt(0) ?? 0);
    return value;
  }

  String totalDue() {
    double? total = _calculateTotalDue();
    var service = _calculateService() * users.length;

    return currency((total ?? 0) + service);
  }

  double? _calculateTotalDue() {
    double? total = null;
    var users = selectedMenus.value.entries.map((e) => e.key).toList();
    users.forEach((user) {
      var calculate = _calculate(user: user);
      var gTotal = calculate.elementAt(2);
      if (gTotal != null) {
        total ??= 0;
        total = total! + gTotal;
      }
    });
    return total ?? 0;
  }

  String totalPaid() {
    var sum = paids.values.map((e) => e ?? 0).toList().sum;
    return "${currency(sum)} of\n${currency(grandTotal.value)}";
  }

  save() {
    box.put("choose", selectedMenus.value);
    box.put("paid", paids);
  }

  load() {
    selectedMenus.value = box.get("choose", defaultValue: {})?.cast() ?? {};
    paids.value = box.get("paid")?.cast() ?? {};
  }

  copy() {}

  showMenu() {
    Get.dialog(MenuForm(menu));
  }

  String sumService() {
    double value = _calculateSumService();
    return currency(value);
  }

  double _calculateSumService() {
    var value = _calculateService() * users.length;
    return value;
  }
}
