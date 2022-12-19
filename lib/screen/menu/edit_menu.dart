import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_order/model/category.dart';
import 'package:food_order/model/menu.dart';
import 'package:image_picker/image_picker.dart';

class EditMenu extends StatefulWidget {
  final Category category;
  final Menu menu;

  const EditMenu({required this.category, required this.menu});

  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? file;
  bool submit = false;

  @override
  void initState() {
    _nameController.text = widget.menu.name;
    _priceController.text = (widget.menu.price / 100).toStringAsFixed(2);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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

  void _submit(String name, num price) async {
    setState(() {
      submit = true;
    });

    Map<String, dynamic> data;

    if (file != null) {
      final firebaseStorage = FirebaseStorage.instance;

      var snapshot =
          await firebaseStorage.ref().child('images/menu/$name').putFile(file!);
      var imageUrl = await snapshot.ref.getDownloadURL();

      data = {'name': name, 'imageUrl': imageUrl, 'price': price};
    } else {
      data = {'name': name, 'price': price};
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref
        .child('categories/${widget.category.id}/menus/${widget.menu.id}')
        .update(data)
        .then((value) {
      setState(() {
        submit = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Menu updated'),
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

  _delete() {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref
        .child('categories/${widget.category.id}/menus/${widget.menu.id}')
        .remove()
        .then((value) {
      setState(() {
        submit = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Menu deleted'),
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
        title: const Text("Edit Menu"),
        actions: [
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete))
        ],
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
                          : NetworkImage(widget.menu.imageUrl) as ImageProvider,
                      child: file != null || widget.menu.imageUrl.isNotEmpty
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
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
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
                            num price = num.parse(_priceController.text) * 100;
                            _submit(name, price);
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
