import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/provider/cart_provider.dart';
import 'package:food_order/provider/menu_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  @override
  Widget build(BuildContext context) {
    return Selector<MenuProvider, DatabaseReference?>(
        selector: (_, notifier) => notifier.dbMenuRef,
        builder: (_, value, __) {
          return value != null
              ? StreamBuilder(
                  stream: value.onValue,
                  builder: (context, snapshot) {
                    List<Menu> menus = [];
                    if (snapshot.hasData && snapshot.data != null) {
                      for (var child in snapshot.data!.snapshot.children) {
                        Map value = child.value as Map;
                        Map<String, dynamic> data = {
                          '_id': child.key,
                          'imageUrl': value['imageUrl'],
                          'name': value['name'],
                          'price': value['price']
                        };

                        menus.add(Menu.fromJson(data));
                      }

                      return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.5,
                          ),
                          itemCount: menus.length,
                          itemBuilder: (BuildContext context, int index) {
                            Menu menu = menus[index];
                            return ChangeNotifierProvider<CartProvider>(
                              create: (context) => CartProvider(
                                menu: menu,
                              ),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              menu.imageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Incrementor(),
                                      const Spacer(),
                                      const AddToCart(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Consumer<MenuProvider>(
                        builder: (context, menu, child) {
                          return Scaffold(
                            body: Text(menu.dbMenuRef.toString()),
                          );
                        },
                      );
                    }
                  })
              : Container();
        });
  }
}

class Incrementor extends StatelessWidget {
  const Incrementor({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);
    return Selector<CartProvider, Menu>(
      selector: (_, notifier) => notifier.menu,
      builder: (context, data, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(provider.menu.name)],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(provider.priceInRM)],
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: () {
                        provider.decrease();
                      },
                      child: const Icon(Icons.remove)),
                  Text(provider.quantity.toString()),
                  InkWell(
                      onTap: () {
                        provider.increase();
                      },
                      child: const Icon(Icons.add)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddToCart extends StatelessWidget {
  const AddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    CartController cartController = Get.put(CartController());
    final provider = Provider.of<CartProvider>(context);
    final menu = provider.menu;
    return Selector<CartProvider, Menu>(
        selector: (_, notifier) => notifier.menu,
        builder: (context, data, child) {
          return SizedBox(
            height: 30,
            child: ElevatedButton(
                onPressed: () async {
                  int quantity = provider.quantity;
                  bool test =
                      await cartController.addItem(menu, quantity, context);
                  if (test) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Added to cart'),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                                child: const Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Failed'),
                            content: const Text('Faile added to cart'),
                            actions: <Widget>[
                              TextButton(
                                style: TextButton.styleFrom(
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                                child: const Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }
                },
                child: const Text("Add")),
          );
        });
  }
}
