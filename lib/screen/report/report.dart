import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/drawer/drawer_menu.dart';
import 'package:food_order/model/order.dart';
import 'package:food_order/screen/report/report_details.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final reportRef = FirebaseDatabase.instance.ref("orders");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text("Report"),
      ),
      body: StreamBuilder(
          stream: reportRef.onValue,
          builder: (context, snapshot) {
            List<Report> reports = [];
            if (snapshot.hasData && snapshot.data != null) {
              for (var child in snapshot.data!.snapshot.children) {
                Map value = child.value as Map;
                List<Map<String, dynamic>> menus = [];
                List<dynamic> test = value['menus'] as List<dynamic>;
                for (var element in test) {
                  Map<String, dynamic> data = {
                    '_id': element['_id'],
                    'imageUrl': element['imageUrl'],
                    'name': element['name'],
                    'price': element['price'],
                    'quantity': element['quantity']
                  };
                  menus.add(data);
                }

                Map<String, dynamic> data = {
                  '_id': child.key,
                  'balance': value['balance'],
                  'table': value['table'],
                  'date': value['date'],
                  'menus': menus,
                  'payment': value['payment'],
                };

                reports.add(Report.fromJson(data));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: reports.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Report report = reports[index];
                  DateTime date =
                      DateTime.fromMillisecondsSinceEpoch(report.date);
                  String dateF = DateFormat.yMMMd().format(date);
                  return Card(
                    child: ListTile(
                      title: Text(report.id),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateF),
                        ],
                      ),
                      trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetails(
                                  report: report,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chevron_right_sharp)),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No Data"),
              );
            }
          }),
    );
  }
}
