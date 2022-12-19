import 'package:food_order/model/menu.dart';

class Report {
  String id;
  int balance;
  int date;
  List<Menu> menus;
  int payment;

  Report(
      {required this.balance,
      required this.id,
      required this.date,
      required this.menus,
      required this.payment});

  factory Report.fromJson(Map<String, dynamic> data) {
    return Report(
        id: data['_id'],
        balance: data['balance'],
        date: data['date'],
        menus: CartMenuList.fromMap(data['menus']),
        payment: data['payment']);
  }
}
