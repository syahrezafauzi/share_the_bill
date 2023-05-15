import 'dart:js';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_the_bill/controllers/home/home_controller.dart';

class HomePage extends GetResponsiveView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: _body()));
  }

  _body() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() => Row(
                children: [
                  Text(
                    controller.title.value,
                    style: Theme.of(Get.context!)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  VerticalDivider(),
                  IconButton(
                      onPressed: () => controller.save(),
                      icon: Icon(Icons.save)),
                  IconButton(
                      onPressed: () => controller.load(),
                      icon: Icon(Icons.refresh)),
                  IconButton(
                      onPressed: () => controller.copy(),
                      icon: Icon(Icons.copy)),
                ],
              )),
          Divider(),
          _menu(),
          Divider(),
          Divider(
            color: Colors.transparent,
          ),
          Divider(
            color: Colors.transparent,
          ),
          _selectMenu(),
        ],
      ),
    );
  }

  Row _menu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userBill(),
      ],
    );
  }

  Container _selectMenu() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() => Table(
                children: [
                  TableRow(children: [
                    Text(""),
                    Text("Menu"),
                    Text("Price"),
                  ]),
                  ...controller.menu.entries.mapIndexed<TableRow>((i, element) {
                    return TableRow(
                        decoration: BoxDecoration(
                            color: controller.selectedUser.value == null
                                ? Colors.transparent
                                : (i % 2 == 0
                                    ? Colors.grey[200]
                                    : Colors.white)),
                        children: [
                          controller.selectedUser.value == null
                              ? SizedBox.shrink()
                              : Obx(() => Checkbox(
                                    value: controller.isChooseMenu(element.key),
                                    onChanged: (value) => controller.chooseMenu(
                                        element.key,
                                        condition: value),
                                  )),
                          Text(element.key),
                          Text(controller.currency(element.value)),
                        ]);
                  }).toList()
                ],
              )),
        ],
      ),
    );
  }

  Expanded _userBill() {
    return Expanded(
      flex: 1,
      child: Table(children: [
        TableRow(children: [
          Text("Name"),
          Text("Total"),
          Text("Tax ${controller.ppn}%"),
          Text("Due"),
          Text(""),
        ]),
        ...controller.users.value
            .mapIndexed(
              (i, e) => TableRow(
                  decoration: BoxDecoration(
                    color: i % 2 == 0 ? Colors.grey[200] : Colors.white,
                    // backgroundBlendMode: BlendMode.colorBurn,
                  ),
                  children: [
                    Obx(() => ListTile(
                          selected: controller.selectedUser.value != null &&
                              controller.isSelected(e),
                          selectedColor: Colors.blue,
                          selectedTileColor: Colors.blue,
                          // tileColor: controller.isSelected(controller.users.value.elementAt(index)) ? Colors.blue : null,
                          title: Text(e),
                          onTap: () => controller.selectUser(e),
                        )),
                    Obx(() => controller.selectedMenus.value != null
                        ? TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Text(controller.total(e)),
                          )
                        : SizedBox.shrink()),
                    Obx(() => controller.selectedMenus.value != null
                        ? TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Text(controller.totalPpn(e)),
                          )
                        : SizedBox.shrink()),
                    Obx(() => controller.selectedMenus.value != null
                        ? TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Text(
                              controller.sum(e),
                              style: Theme.of(Get.context!)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          )
                        : SizedBox.shrink()),
                    Obx(() =>
                        controller.paids.keys.any((element) => element == e)
                            ? TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Icon(
                                  Icons.local_atm_rounded,
                                  color: Colors.green,
                                ),
                              )
                            : TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: Checkbox(
                                    value: false,
                                    onChanged: (value) => controller.paid(e)),
                              )),
                  ]),
            )
            .toList(),
        TableRow(children: [
          Text(""),
          Text(""),
          Text(""),
          Obx(() => Text(controller.selectedMenus.value != null
              ? controller.totalDue()
              : "")),
          Obx(() => TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  controller.selectedMenus.value != null
                      ? controller.totalPaid()
                      : "",
                  textAlign: TextAlign.center,
                ),
              )),
        ]),
      ]),
    );
  }

  ListView _listUser() {
    return ListView.builder(
        itemCount: controller.users.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => Row(
              children: [
                // Checkbox(
                //   value: false,
                //   onChanged: controller
                //       .selectUser(controller.users.value[index]),
                // ),
                Expanded(
                  child: Obx(() => Row(
                        children: [
                          Obx(() => controller.paids.keys.any((element) =>
                                  element == controller.users.elementAt(index))
                              ? Icon(
                                  Icons.attach_money_rounded,
                                  color: Colors.green,
                                )
                              : Checkbox(
                                  value: false,
                                  onChanged: (value) => controller.paid(
                                      controller.users.value
                                          .elementAt(index)))),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    selected: controller.isSelected(controller
                                        .users.value
                                        .elementAt(index)),
                                    selectedColor: Colors.white,
                                    selectedTileColor: Colors.blue,
                                    // tileColor: controller.isSelected(controller.users.value.elementAt(index)) ? Colors.blue : null,
                                    title: Text(controller.users.value[index]),
                                    onTap: () => controller.selectUser(
                                        controller.users.elementAt(index)),
                                  ),
                                ),
                                Obx(() => controller.selectedMenus.value != null
                                    ? Text(controller
                                        .total(controller.users.value[index]))
                                    : SizedBox.shrink()),
                                VerticalDivider(
                                  color: Colors.transparent,
                                ),
                                Obx(() => controller.selectedMenus.value != null
                                    ? Text(controller.totalPpn(
                                        controller.users.value[index]))
                                    : SizedBox.shrink()),
                                VerticalDivider(
                                  color: Colors.transparent,
                                ),
                                Obx(() => controller.selectedMenus.value != null
                                    ? Text(controller
                                        .sum(controller.users.value[index]))
                                    : SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ));
  }

  // ListView _listItem() {
  //   return ListView.builder(
  //     itemCount: controller.menu.length,
  //     shrinkWrap: true,
  //     itemBuilder: (context, index) => Row(
  //       children: [
  //         Checkbox(
  //             value: false,
  //             onChanged: (value) =>
  //                 controller.chooseMenu(controller.menu[index], value)),
  //         Text(controller.menu.keys.elementAt(index)),
  //       ],
  //     ),
  //   );
  // }
}
