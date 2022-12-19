import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food_order/model/category.dart';
import 'package:image_picker/image_picker.dart';

class EditCategory extends StatefulWidget {
  final Category category;

  const EditCategory({required this.category});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  Category? category;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? file;
  bool submit = false;

  @override
  void initState() {
    category = widget.category;
    _nameController.text = category!.name;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  _getFromGallery() async {
    try {
      // await Permission.photos.request();
      // var permissionStatus = await Permission.photos.status;

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          file = File(pickedFile.path);
        });
      }
    } catch (e) {}
  }

  void _submit(String name) async {
    setState(() {
      submit = true;
    });
    Map<String, dynamic> data = {};

    if (file != null) {
      final firebaseStorage = FirebaseStorage.instance;
      var snapshot = await firebaseStorage
          .ref()
          .child('images/categories/$name')
          .putFile(file!);
      var imageUrl = await snapshot.ref.getDownloadURL();

      data = {'name': name, 'imageUrl': imageUrl};
    } else {
      data = {
        'name': name,
      };
    }

    print(data);

    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref.child('categories/${category!.id}').update(data).then((value) {
      setState(() {
        submit = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Category updated'),
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
      setState(() {
        submit = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _getFromGallery,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: file != null
                          ? FileImage(
                              file!,
                            )
                          : NetworkImage(category!.imageUrl) as ImageProvider,
                      child: file != null || category!.imageUrl.isNotEmpty
                          ? Container()
                          : const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                validator: (String? value) {
                  if (value != null && value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: !submit
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            String name = _nameController.text;
                            _submit(name);
                          }
                        }
                      : null,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
