class Category {
  String id;
  String imageUrl;
  String name;

  Category({required this.id, required this.imageUrl, required this.name});

  factory Category.fromJson(Map<String, dynamic> data) {
    return Category(
        id: data['_id'], imageUrl: data['imageUrl'], name: data['name']);
  }
}
