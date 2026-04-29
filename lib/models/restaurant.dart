class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isMostSelling;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isMostSelling = false,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? category,
    bool? isMostSelling,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      isMostSelling: isMostSelling ?? this.isMostSelling,
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String image;
  final String rating;
  final String time;
  final bool isBusy;
  final List<String> tags;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.time,
    this.isBusy = false,
    required this.tags,
    required this.menu,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? rating,
    String? time,
    bool? isBusy,
    List<String>? tags,
    List<MenuItem>? menu,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      time: time ?? this.time,
      isBusy: isBusy ?? this.isBusy,
      tags: tags ?? this.tags,
      menu: menu ?? this.menu,
    );
  }
}
