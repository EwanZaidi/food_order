import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/model/category.dart';
import 'package:food_order/provider/menu_provider.dart';
import 'package:provider/provider.dart';

class CatListScreen extends StatefulWidget {
  const CatListScreen({super.key});

  @override
  State<CatListScreen> createState() => _CatListScreenState();
}

class _CatListScreenState extends State<CatListScreen> {
  final categoryRef = FirebaseDatabase.instance.ref("categories");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: categoryRef.onValue,
        builder: (context, snapshot) {
          List<Category> categories = [];
          if (snapshot.hasData && snapshot.data != null) {
            for (var child in snapshot.data!.snapshot.children) {
              Map value = child.value as Map;
              Map<String, dynamic> data = {
                '_id': child.key,
                'imageUrl': value['imageUrl'],
                'name': value['name']
              };

              categories.add(Category.fromJson(data));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                final provider = Provider.of<MenuProvider>(context);
                Category category = categories[index];
                return Consumer<MenuProvider>(builder: (context, menu, child) {
                  return InkWell(
                    onTap: () {
                      menu.menuDatabaseRef('categories/${category.id}/menus');
                      // selectCategory(category);
                    },
                    child: Card(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(category.imageUrl),
                              opacity: 0.5,
                              fit: BoxFit.cover),
                        ),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  );
                });
              },
            );
          } else {
            return Container();
          }
        });
  }
}
