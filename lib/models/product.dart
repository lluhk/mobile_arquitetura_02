// models/product.dart
//
// Modelo de produto para o CRUD.
// O campo id é nullable pois produtos novos ainda não têm id atribuído.
//
// CORREÇÃO: toJson() agora manda "thumbnail" em vez de "image",
// alinhando com o schema da DummyJSON. fromJson() lê "thumbnail"
// com fallback para "image" por compatibilidade.

class Product {
  final int? id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      // DummyJSON usa "thumbnail"; fallback para "image" por compatibilidade
      image: json['thumbnail'] as String? ?? json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'thumbnail': image, // DummyJSON espera "thumbnail", não "image"
    };
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}