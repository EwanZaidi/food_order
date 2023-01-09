import 'package:flutter/material.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/model/order.dart';
import 'package:intl/intl.dart';

class ReportDetails extends StatefulWidget {
  final Report report;

  const ReportDetails({required this.report});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  @override
  Widget build(BuildContext context) {
    Report report = widget.report;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(report.date);
    String dateF = DateFormat.yMMMd().format(date);
    int total = report.payment - report.balance;
    String totalInRM = "RM${(total / 100).toStringAsFixed(2)}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateF,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            if (widget.report.table != null)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Table Number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.report.table!,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Price",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalInRM,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.menus.length,
              itemBuilder: (context, index) {
                Menu menu = report.menus[index];
                int total = menu.price * menu.quantity!;
                String totalInRM = "RM${(total / 100).toStringAsFixed(2)}";
                String subtitle =
                    "RM${(menu.price / 100).toStringAsFixed(2)} x ${menu.quantity}";
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        menu.imageUrl,
                      ), // no matter how big it is, it won't overflow
                    ),
                    title: Text(menu.name),
                    subtitle: Text(subtitle),
                    trailing: Text(totalInRM),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
