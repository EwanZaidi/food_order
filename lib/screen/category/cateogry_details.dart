import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:food_order/model/category.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/provider/menu_provider.dart';
import 'package:food_order/screen/category/category_edit.dart';
import 'package:food_order/screen/menu/add_menu.dart';
import 'package:food_order/screen/menu/edit_menu.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CategoryDetails extends StatefulWidget {
  final Category category;

  const CategoryDetails({required this.category});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  DatabaseReference? menuRef;

  @override
  void initState() {
    // TODO: implement initState
    menuRef =
        FirebaseDatabase.instance.ref("categories/${widget.category.id}/menus");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Details"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCategory(
                      category: widget.category,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                FirebaseDatabase.instance
                    .ref("categories/${widget.category.id}")
                    .remove()
                    .then((value) => Navigator.pop(context));
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMenu(
                category: widget.category,
              ),
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          padding: const EdgeInsets.all(15),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
            stream: menuRef!.onValue,
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
                return Column(
                  children: [
                    if (menus.isNotEmpty)
                      Row(
                        children: const [
                          Text("Menu List"),
                        ],
                      )
                    else
                      Row(
                        children: const [
                          Text("No Menu"),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 1.5),
                        ),
                        itemCount: menus.length,
                        itemBuilder: (BuildContext context, int index) {
                          Menu menu = menus[index];
                          return ChangeNotifierProvider<MenuProvider>(
                            create: (context) => MenuProvider(
                              menu: menu,
                            ),
                            child: InkWell(
                              onLongPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditMenu(
                                      category: widget.category,
                                      menu: menu,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              menu.imageUrl,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Incrementor(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const AddToCart(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                  ],
                );
              } else {
                return const Center(
                  child: Text("Loading"),
                );
              }
            }),
      ),
    );
  }
}

class Incrementor extends StatelessWidget {
  const Incrementor({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
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
  }
}

class AddToCart extends StatelessWidget {
  const AddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    CartController cartController = Get.put(CartController());
    final provider = Provider.of<MenuProvider>(context);
    final menu = provider.menu;
    return SizedBox(
      height: 30,
      child: ElevatedButton(
          onPressed: () async {
            menu.quantity = provider.quantity;
            bool test = await cartController.addItem(menu);
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
            }
          },
          child: const Text("Add to Cart")),
    );
  }
}
