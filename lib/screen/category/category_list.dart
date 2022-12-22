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

              return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    Category category = categories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryDetails(
                              category: category,
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
                                category.imageUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Text("No Data"),
              );
            }
          }),
    );
  }
}
