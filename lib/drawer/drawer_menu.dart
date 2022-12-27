import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_order/controller/cart.controller.dart';
import 'package:food_order/screen/new_layout/new_pos.dart';
import 'package:food_order/screen/report/report.dart';
import 'package:food_order/signin.dart';
import 'package:get/get.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      padding:
          EdgeInsets.only(left: 24, top: MediaQuery.of(context).padding.top),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("POS"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const NewPosScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("SALES REPORT"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ReportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              CartController cartController = Get.put(CartController());
              const storage = FlutterSecureStorage();
              await _auth.signOut();
              await storage.deleteAll();
              cartController.clear();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignIn(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
