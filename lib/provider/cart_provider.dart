import 'package:flutter/cupertino.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:food_order/model/menu.dart';
import 'package:get/get.dart';

class CartProvider extends ChangeNotifier {
  Menu menu;
  int quantity = 1;

  CartProvider({required this.menu}) {
    quantity = menu.quantity != null ? menu.quantity! : 1;
    notifyListeners();
  }

  increase() {
    final CartController cartController = Get.find<CartController>();
    Menu cartItem;
    List<Menu> cartItems =
        cartController.menus.where((pr) => pr.id == menu.id).toList();

    if (cartItems.isNotEmpty) {
      cartItem = cartItems[0];
      quantity++;
    } else {
      quantity++;
    }

    notifyListeners();
  }

  decrease() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  int get price {
    int price = menu.price;

    return price;
  }

  String get priceToString {
    int total = price;

    return (total / 100).toStringAsFixed(2);
  }

  double get total {
    int total = price;
    return (total / 100) * quantity;
  }

  String get totalInRM => 'RM${total.toStringAsFixed(2)}';
  String get priceInRM => 'RM${(price / 100).toStringAsFixed(2)}';
}
