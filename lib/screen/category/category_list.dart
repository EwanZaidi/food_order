import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/model/category.dart';
import 'package:food_order/screen/category/category_add.dart';
import 'package:food_order/screen/category/cateogry_details.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final categoryRef = FirebaseDatabase.instance.ref("categories");

  @override
  void initState() {
    // test(); // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCategory(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
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

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: categories.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          categories[index].imageUrl,
                        ), // no matter how big it is, it won't overflow
                      ),
                      title: Text(categories[index].name),
                      trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetails(
                                  category: categories[index],
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
