class MenuCategory {
  final String title;
  final List<MenuItem> items;

  MenuCategory({required this.title, required this.items});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List;
    List<MenuItem> itemsList =
        itemsJson.map((item) => MenuItem.fromJson(item)).toList();
    return MenuCategory(title: json['title'], items: itemsList);
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String image;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'], // Thêm dòng này
      name: json['name'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }
}
