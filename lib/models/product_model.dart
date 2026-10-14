class Product {
  final int? id;
  final String name;
  final double price;
  final String category; 
  final String brand;    
  final int totalStock;
  final int boughtCount;
  final double rating;
  final bool isActive;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.brand,
    required this.totalStock,
    this.boughtCount = 0,
    required this.rating,
    this.isActive = true,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'category': category,
      'brand': brand,
      'total_stock': totalStock,
      'bought_count': boughtCount,
      'rating': rating,
      'is_active': isActive ? 1 : 0,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      brand: map['brand'] as String,
      totalStock: map['total_stock'] as int,
      boughtCount: (map['bought_count'] as int?) ?? 0,
      rating: (map['rating'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      description: map['description'] as String,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
    String? brand,
    int? totalStock,
    int? boughtCount,
    double? rating,
    bool? isActive,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      totalStock: totalStock ?? this.totalStock,
      boughtCount: boughtCount ?? this.boughtCount,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}