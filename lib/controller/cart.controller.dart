import 'package:food_order/model/menu.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  RxList<Menu> menus = <Menu>[].obs;
  int pay = 0;

  Future<bool> addItem(Menu menu, int quantity, context) async {
    bool isAdded = false;
    int index = List.from(menus).indexWhere((e) => e.id == menu.id);

    if (index == -1) {
      menu.quantity = quantity;
      menus.add(menu);
      isAdded = true;
    } else {
      menus[index].quantity = menus[index].quantity! + quantity;
      isAdded = true;
    }

    menus.refresh();

    return isAdded;
  }

  Rx<Menu> get(int index) {
    return menus[index].obs;
  }

  addQuantity(int index) {
    Menu menu = get(index).value;
    menu.quantity = menu.quantity! + 1;
    menus.refresh();
  }

  removeQuantity(int index) {
    Menu menu = get(index).value;
    if (menu.quantity! > 1) {
      menu.quantity = menu.quantity! - 1;
      menus.refresh();
    }
  }

  int get totalPrice {
    int total = 0;

    for (var element in menus) {
      total = total + (element.price * element.quantity!);
    }

    return total;
  }

  int get balance {
    int total = totalPrice;
    total = total - pay;
    return total;
  }

  String get totalPriceInRM => "RM ${(totalPrice / 100).toStringAsFixed(2)}";
  String get totalBalanceInRM => "RM ${(balance / 100).toStringAsFixed(2)}";

  set payment(int total) {
    pay = total;
    refresh();
  }

  clear() {
    menus.clear();
    menus.refresh();
    refresh();
  }
}
