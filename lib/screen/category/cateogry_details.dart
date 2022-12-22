import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/model/category.dart';
import 'package:food_order/model/menu.dart';
import 'package:food_order/screen/category/category_edit.dart';
import 'package:food_order/screen/menu/add_menu.dart';
import 'package:food_order/screen/menu/edit_menu.dart';

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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: menus.length,
                        itemBuilder: (BuildContext context, int index) {
                          Menu menu = menus[index];
                          return InkWell(
                            onTap: () {
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
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      menu.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        menu.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      Text(
                                        "RM${(menu.price / 100).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
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
