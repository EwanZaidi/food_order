import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/provider/menu_provider.dart';
import 'package:food_order/screen/new_layout/categories.dart';
import 'package:food_order/screen/new_layout/menus.dart';
import 'package:food_order/screen/pos/pos.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NewPosScreen extends StatefulWidget {
  const NewPosScreen({super.key});

  @override
  State<NewPosScreen> createState() => _NewPosScreenState();
}

class _NewPosScreenState extends State<NewPosScreen> {
  final categoryRef = FirebaseDatabase.instance.ref("categories");
  DatabaseReference? menuRef;
  CartController cartController = Get.put(CartController());
  num balance = 0;
  num pay = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width / 1.5,
                child: ChangeNotifierProvider<MenuProvider>(
                  create: (context) => MenuProvider.instance(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: CatListScreen()),
                      Container(
                        height: height,
                        width: 3.0,
                        color: Colors.black,
                      ),
                      const Expanded(child: MenuListScreen()),
                      Container(
                        height: height,
                        width: 3.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: PosScreen()),

              // Builder(builder: (context) {
              //   return Obx(
              //     () => Scaffold(
              //       bottomNavigationBar: SizedBox(
              //         height: 50,
              //         child: ElevatedButton(
              //           onPressed: () async {
              //             submit(pay, balance);
              //           },
              //           child: const Text("Pay"),
              //         ),
              //       ),
              //       body: Padding(
              //         padding: const EdgeInsets.all(20.0),
              //         child: Column(
              //           children: [
              //             ListView.builder(
              //               shrinkWrap: true,
              //               itemCount: cartController.menus.length,
              //               itemBuilder: (context, index) {
              //                 Menu menu = cartController.menus[index];
              //                 return ChangeNotifierProvider<CartProvider>(
              //                   create: (context) => CartProvider(menu: menu),
              //                   child: Card(
              //                     child: ListTile(
              //                       leading: CircleAvatar(
              //                         radius: 20,
              //                         backgroundImage:
              //                             NetworkImage(menu.imageUrl),
              //                       ),
              //                       title: Text(menu.name),
              //                       subtitle: Subtitle(index: index),
              //                       trailing: const Total(),
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //             const SizedBox(
              //               height: 20,
              //             ),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 const Text("Total"),
              //                 Text(cartController.totalPriceInRM)
              //               ],
              //             ),
              //             const SizedBox(
              //               height: 10,
              //             ),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 const Text("Payment"),
              //                 SizedBox(
              //                   width: 100,
              //                   child: TextFormField(
              //                     keyboardType: TextInputType.number,
              //                     onChanged: (value) {
              //                       if (value.isNotEmpty) {
              //                         pay = num.parse(value) * 100;
              //                         balance =
              //                             pay - cartController.totalPrice;
              //                       } else {
              //                         balance = cartController.totalPrice;
              //                       }

              //                       setState(() {});
              //                     },
              //                     decoration: const InputDecoration(
              //                         border: OutlineInputBorder()),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             const SizedBox(
              //               height: 10,
              //             ),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 const Text("Balance"),
              //                 Text("RM${(balance / 100).toStringAsFixed(2)}")
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   );
              // }),
            ],
          ),
        ),
      ),
    );
  }

  submit(num payment, num bal) {
    Map<String, dynamic> data = {
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
}
