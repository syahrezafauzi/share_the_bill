import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:share_the_bill/controllers/home/menu_form_binding.dart';
import 'package:share_the_bill/controllers/home/menu_form_controller.dart';

class MenuForm<Binding extends Bindings, Controller>
    extends GetWidget<MenuFormController> {
  final RxMap<String, double> menus;
  MenuForm(this.menus);
  @override
  Widget build(BuildContext context) {
    _createBinding();
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Table(
                  children: [
                    TableRow(children: [
                      Text("Name"),
                      Text("Price"),
                    ]),
                    ...(menus.entries.map((e) => TableRow(children: [
                          Text(e.key),
                          Text(controller.toCurrency(e.value)),
                        ])))
                  ],
                ),
              )
            ]),
      ),
    );
  }

  void _createBinding() {
    
    var binding = MenuFomBinding();
    binding.dependencies();
  }
}
