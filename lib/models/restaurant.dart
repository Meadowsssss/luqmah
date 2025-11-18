
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String image;
  final String rating;
  final String time;
  final List<String> tags;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.time,
    required this.tags,
    required this.menu,
  });
}
