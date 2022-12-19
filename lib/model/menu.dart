class Menu {
  String id;
  String imageUrl;
  String name;
  int price;
  int? quantity;

  Menu(
      {required this.id,
      required this.imageUrl,
      required this.name,
      required this.price,
      this.quantity});

  factory Menu.fromJson(Map<String, dynamic> data) {
    Menu menu = Menu(
        id: data['_id'],
        imageUrl: data['imageUrl'],
        name: data['name'],
        price: data['price']);

    if (data['quantity'] != null) {
      menu.quantity = data['quantity'];
    }

    return menu;
  }

  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "imageUrl": imageUrl,
      "name": name,
      "price": price,
      "quantity": quantity
    };
  }
}

class CartMenuList {
  static List<Menu> fromMap(List<dynamic> data) {
    List<Menu> menus = [];
    for (var e in data) {
      final menu = Menu.fromJson(e);
      menus.add(menu);
    }
    return menus;
  }

  static List<Map<String, dynamic>> toMap(List<Menu> list) {
    return list.map((e) => e.toMap()).toList();
  }
}
