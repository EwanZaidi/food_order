import 'package:food_order/model/menu.dart';

class Report {
  String id;
  int balance;
  int date;
  List<Menu> menus;
  int payment;
  String? table;

  Report(
      {required this.balance,
      required this.id,
      required this.date,
      required this.menus,
      this.table,
      required this.payment});

  factory Report.fromJson(Map<String, dynamic> data) {
    Report report = Report(
        id: data['_id'],
        balance: data['balance'],
        date: data['date'],
        menus: CartMenuList.fromMap(data['menus']),
        payment: data['payment']);

    if (data['table'] != null) {
      report.table = data['table'];
    }

    return report;
  }
}
