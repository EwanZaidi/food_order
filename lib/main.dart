import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_order/main_menu.dart';
import 'package:food_order/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? uid;
  bool fetch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
  }

  getUid() async {
    const storage = FlutterSecureStorage();
    uid = await storage.read(key: 'token');

    setState(() {
      fetch = true;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return fetch
        ? MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: uid != null ? const MainMenuScreen() : const SignIn(),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
