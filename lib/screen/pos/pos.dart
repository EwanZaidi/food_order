import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/provider/cart_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  CartController cartController = Get.put(CartController());
  num balance = 0;
  num pay = 0;
  String table = '';
  final tableRef = FirebaseDatabase.instance.ref("tables");
  @override
  void initState() {
    // TODO: implement initState
    balance = cartController.totalPrice;
    super.initState();
  }

  submit(num payment, num bal) {
    Map<String, dynamic> data = {
      'table': table,
      'payment': payment,
      'balance': bal,
      'menus': CartMenuList.toMap(cartController.menus),
      'date': DateTime.now().toLocal().millisecondsSinceEpoch
    };

    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref.child('orders').push().set(data).then((value) {
      cartController.clear();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Payment success'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Failed'),
              content: Text(err.toString()),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Obx(
        () => Scaffold(
          bottomNavigationBar: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Printer'),
                          content: const Text('Printer Not Found'),
                          actions: <Widget>[
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('Okay'),
                              onPressed: () {
                                submit(pay, balance);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              },
              child: const Text("Pay"),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartController.menus.length,
                  itemBuilder: (context, index) {
                    Menu menu = cartController.menus[index];
                    return ChangeNotifierProvider<CartProvider>(
                      create: (context) => CartProvider(menu: menu),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(menu.imageUrl),
                          ),
                          title: Text(menu.name),
                          subtitle: Subtitle(index: index),
                          trailing: const Total(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                    stream: tableRef.onValue,
                    builder: (context, snapshot) {
                      List<String> tables = [];
                      tables.add('');
                      if (snapshot.hasData && snapshot.data != null) {
                        for (var child in snapshot.data!.snapshot.children) {
                          tables.add(child.value.toString());
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Table"),
                            DropdownButton<String>(
                              value: table,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              underline: Container(),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  table = value!;
                                });
                              },
                              items: tables.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: Text("No Data"),
                        );
                      }
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total"),
                    Text(cartController.totalPriceInRM)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Payment"),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            pay = num.parse(value) * 100;
                            balance = pay - cartController.totalPrice;
                          } else {
                            balance = cartController.totalPrice;
                          }

                          setState(() {});
                        },
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Balance"),
                    Text("RM${(balance / 100).toStringAsFixed(2)}")
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class Total extends StatelessWidget {
  const Total({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);
    return Text(provider.totalInRM);
  }
}

class Subtitle extends StatelessWidget {
  const Subtitle({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    CartController cartController = Get.put(CartController());
    final provider = Provider.of<CartProvider>(context);
    final menu = provider.menu;
    provider.quantity = provider.menu.quantity!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quantity : ${menu.quantity}"),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    provider.decrease();
                    cartController.removeQuantity(index);
                  },
                  child: const Icon(Icons.remove)),
              Text(provider.quantity.toString()),
              InkWell(
                  onTap: () {
                    provider.increase();
                    cartController.addQuantity(index);
                  },
                  child: const Icon(Icons.add)),
            ],
          ),
        )
      ],
    );
  }
}
