enum MenuItemOptionSelectionType { single, multiple }

class MenuItemOption {
  const MenuItemOption({
    required this.id,
    required this.title,
    required this.priceDelta,
  });

  final String id;
  final String title;
  final double priceDelta;
}

class MenuItemOptionGroup {
  const MenuItemOptionGroup({
    required this.id,
    required this.title,
    required this.selectionType,
    required this.isRequired,
    required this.options,
  });

  final String id;
  final String title;
  final MenuItemOptionSelectionType selectionType;
  final bool isRequired;
  final List<MenuItemOption> options;

  bool get isSingleChoice => selectionType == MenuItemOptionSelectionType.single;
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isMostSelling;
  final List<MenuItemOptionGroup> optionGroups;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isMostSelling = false,
    this.optionGroups = const [],
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? category,
    bool? isMostSelling,
    List<MenuItemOptionGroup>? optionGroups,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      isMostSelling: isMostSelling ?? this.isMostSelling,
      optionGroups: optionGroups ?? this.optionGroups,
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String image;
  final String rating;
  final double? averageRating;
  final int ratingCount;
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
    this.averageRating,
    this.ratingCount = 0,
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
    double? averageRating,
    int? ratingCount,
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
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      time: time ?? this.time,
      isBusy: isBusy ?? this.isBusy,
      tags: tags ?? this.tags,
      menu: menu ?? this.menu,
    );
  }
}
