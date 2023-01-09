import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_order/drawer/drawer_menu.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  final tableRef = FirebaseDatabase.instance.ref("tables");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text("Table"),
        actions: [
          IconButton(
            onPressed: () {
              _displayTextInputDialog(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: tableRef.onValue,
          builder: (context, snapshot) {
            List<String> tables = [];
            if (snapshot.hasData && snapshot.data != null) {
              for (var child in snapshot.data!.snapshot.children) {
                tables.add(child.value.toString());
              }

              return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {},
                      child: Card(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Text(
                              tables[index],
                              style: const TextStyle(
                                color: Colors.black,
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

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return const MyAlertDialog();
        });
  }
}

class MyAlertDialog extends StatefulWidget {
  const MyAlertDialog({super.key});

  @override
  State<MyAlertDialog> createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  TextEditingController textFieldController = TextEditingController();
  String valueText = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter table number'),
      content: TextField(
        onChanged: (value) {
          setState(() {
            valueText = value;
          });
        },
        keyboardType: TextInputType.number,
        controller: textFieldController,
        decoration: const InputDecoration(hintText: "Table number"),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            _submit(valueText);
          },
        ),
      ],
    );
  }

  void _submit(String name) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref.child('tables').push().set(valueText).then((value) {
      setState(() {
        Navigator.pop(context);
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('New table added'),
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
      setState(() {
        Navigator.pop(context);
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
}
