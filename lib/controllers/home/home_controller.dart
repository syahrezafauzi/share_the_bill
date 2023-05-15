
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  late Box<Map> box;
  var left = Rx<double>(0);
  var grandTotal = Rx<double?>(469700);
  var title = "Bill lunch @CITY ICE CREAM".obs;
  var menu = <String, double>{
    "MARTABAK MESIR PANAS": 35000,
    "MIE TIAW KUAH": 36000,
    "NASI CAP CAI GORENG": 39000,
    "NASI AYAM KECAP": 40000,
    "NASI KARI DAGING SAPI": 42000,
    "CHICKEN BURGER": 30000,
    "CHICKEN SPRING ROLL": 22000,
    "CITY LINK": 22000,
    "TAHU BALIK TUNA": 20000,
    "ICE CREAM SHAKE": 28000,
    "ICE WATER CHESTNUT": 20000,
    "HOT TEA": 36000,
    "HOT LEMON TEA": 20000,
    "SODA MILK": 19000,
    "AQUA CUP": 0
  };
  var ppn = 10.obs;
  var users = <String>[
    "Reza",
    "Willy",
    "Eric",
    "Nanda",
    "Pipin",
    "Tinesh",
    "Theresia",
    "Rivaldo",
  ].obs;

  var totals = <double>[].obs;

  var paids = <String, double?>{}.obs;

  var selectedUser = Rx<String?>(null);
  var selectedMenus = Rx<Map<String, List<String>>>({});

  String get getGrandTotal => formatCurrency.format(grandTotal.value);
  final formatCurrency = NumberFormat.simpleCurrency(locale: "id-ID");

  @override
  void onInit(){
    super.onInit();
    _init();
  }

  void _init() async{
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
      var calculate = _calculate(user);
      var entry = paids.entries.where((element) => element.key == user).firstOrNull;
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

  List<double?> _calculate(String user) {
    var result = <double?>[null, null, null];
    var items = selectedMenus.value.entries
        .where((element) => element.key == user)
        .firstOrNull
        ?.value;
    if (items != null) {
      var total = menu.entries
          .where((element) => items.contains(element.key))
          .map((e) => e.value)
          .sum;
      var _ppn = ppn / 100 * total;
      var gTotal = total + _ppn;
      result[0] = total;
      result[1] = _ppn;
      result[2] = gTotal;
    }

    return result;
  }

  String total(String user) {
    var calculate = _calculate(user);
    return currency(calculate.elementAt(0));
  }

  String totalPpn(String user) {
    var calculate = _calculate(user);
    return currency(calculate.elementAt(1));
  }

  String sum(String user) {
    var calculate = _calculate(user);
    return currency(calculate.elementAt(2));
  }

  String totalDue() {
    double? total = null;
    var users = selectedMenus.value.entries.map((e) => e.key).toList();
    users.forEach((user) {
      var calculate = _calculate(user);
      var gTotal = calculate.elementAt(2);
      if (gTotal != null) {
        total ??= 0;
        total = total! + gTotal;
      }
    });

    return currency(total);
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
}
