enum Category { all, accessories, clothing, home }

class ProductsRepository {
  static const _allProducts = <Product>[
    Product(
      category: Category.accessories,
      id: 0,
      name: 'Vagabond sack',
      price: 120,
    ),
    Product(
      category: Category.accessories,
      id: 1,
      name: 'Stella sunglasses',
      price: 58,
    ),
    Product(
      category: Category.accessories,
      id: 2,
      name: 'Whitney belt',
      price: 35,
    ),
    Product(
      category: Category.accessories,
      id: 3,
      name: 'Garden strand',
      price: 98,
    ),
    Product(
      category: Category.accessories,
      id: 4,
      name: 'Strut earrings',
      price: 34,
    ),
    Product(
      category: Category.accessories,
      id: 5,
      name: 'Varsity socks',
      price: 12,
    ),
    Product(
      category: Category.accessories,
      id: 6,
      name: 'Weave keyring',
      price: 16,
    ),
    Product(
      category: Category.accessories,
      id: 7,
      name: 'Gatsby hat',
      price: 40,
    ),
    Product(
      category: Category.accessories,
      id: 8,
      name: 'Shrug bag',
      price: 198,
    ),
    Product(category: Category.home, id: 9, name: 'Gilt desk trio', price: 58),
    Product(
      category: Category.home,
      id: 10,
      name: 'Copper wire rack',
      price: 18,
    ),
    Product(
      category: Category.home,
      id: 11,
      name: 'Soothe ceramic set',
      price: 28,
    ),
    Product(
      category: Category.home,
      id: 12,
      name: 'Hurrahs tea set',
      price: 34,
    ),
    Product(category: Category.home, id: 13, name: 'Blue stone mug', price: 18),
    Product(category: Category.home, id: 14, name: 'Rainwater tray', price: 27),
    Product(
      category: Category.home,
      id: 15,
      name: 'Chambray napkins',
      price: 16,
    ),
    Product(
      category: Category.home,
      id: 16,
      name: 'Succulent planters',
      price: 16,
    ),
    Product(category: Category.home, id: 17, name: 'Quartet table', price: 175),
    Product(
      category: Category.home,
      id: 18,
      name: 'Kitchen quattro',
      price: 129,
    ),
    Product(
      category: Category.clothing,
      id: 19,
      name: 'Clay sweater',
      price: 48,
    ),
    Product(category: Category.clothing, id: 20, name: 'Sea tunic', price: 45),
    Product(
      category: Category.clothing,
      id: 21,
      name: 'Plaster tunic',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 22,
      name: 'White pinstripe shirt',
      price: 70,
    ),
    Product(
      category: Category.clothing,
      id: 23,
      name: 'Chambray shirt',
      price: 70,
    ),
    Product(
      category: Category.clothing,
      id: 24,
      name: 'Seabreeze sweater',
      price: 60,
    ),
    Product(
      category: Category.clothing,
      id: 25,
      name: 'Gentry jacket',
      price: 178,
    ),
    Product(
      category: Category.clothing,
      id: 26,
      name: 'Navy trousers',
      price: 74,
    ),
    Product(
      category: Category.clothing,
      id: 27,
      name: 'Walter henley (white)',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 28,
      name: 'Surf and perf shirt',
      price: 48,
    ),
    Product(
      category: Category.clothing,
      id: 29,
      name: 'Ginger scarf',
      price: 98,
    ),
    Product(
      category: Category.clothing,
      id: 30,
      name: 'Ramona crossover',
      price: 68,
    ),
    Product(
      category: Category.clothing,
      id: 31,
      name: 'Chambray shirt',
      price: 38,
    ),
    Product(
      category: Category.clothing,
      id: 32,
      name: 'Classic white collar',
      price: 58,
    ),
    Product(
      category: Category.clothing,
      id: 33,
      name: 'Cerise scallop tee',
      price: 42,
    ),
    Product(
      category: Category.clothing,
      id: 34,
      name: 'Shoulder rolls tee',
      price: 27,
    ),
    Product(
      category: Category.clothing,
      id: 35,
      name: 'Grey slouch tank',
      price: 24,
    ),
    Product(
      category: Category.clothing,
      id: 36,
      name: 'Sunshirt dress',
      price: 58,
    ),
    Product(
      category: Category.clothing,
      id: 37,
      name: 'Fine lines tee',
      price: 58,
    ),
  ];

  static List<Product> loadProducts({Category category = Category.all}) {
    if (category == Category.all) {
      return _allProducts;
    } else {
      return _allProducts.where((p) {
        return p.category == category;
      }).toList();
    }
  }

  static Product loadProduct({required int id}) {
    return _allProducts.firstWhere((p) {
      return p.id == id;
    });
  }
}

String getCategoryTitle(Category category) => switch (category) {
  Category.all => 'All',
  Category.accessories => 'Accessories',
  Category.clothing => 'Clothing',
  Category.home => 'Home',
};


class Product {
  //快捷写法 const Product({}) 后续按tab键自动补全 required 的内容
  const Product({
    required this.category,
    required this.id,
    required this.name,
    required this.price,
  });

  final Category category;
  final int id;
  final String name;
  final int price;

  String get assetName => 'lib/examples/deeplink_store/assets/products/$id-0.jpg';

  String get assetName2X => 'lib/examples/deeplink_store/assets/products/2.0x/$id-0.jpg';
}
