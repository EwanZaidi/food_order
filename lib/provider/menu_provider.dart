import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class MenuProvider extends ChangeNotifier {
  DatabaseReference? ref;
  DatabaseReference? get dbMenuRef => ref;
  bool isLoad = false;
  bool get load => isLoad;

  MenuProvider.instance();

  void menuDatabaseRef(String menu) async {
    ref = null;
    isLoad = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      ref = FirebaseDatabase.instance.ref(menu);
      isLoad = true;
      notifyListeners();
    });
  }
}
