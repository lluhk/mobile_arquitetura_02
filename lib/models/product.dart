// models/product.dart
//
// Modelo de produto para o CRUD (Atividade 09).
// Inclui fromJson e toJson para comunicação com a API.
// O campo id é nullable pois produtos novos ainda não têm id atribuído.
//
// CORREÇÃO: ajustado para o schema da dummyjson.com.
// "image" → "thumbnail" (campo de imagem principal da dummyjson)

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
      // dummyjson usa "thumbnail"; fallback para "image" por compatibilidade
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
      'image': image,
    };
  }

  // Cria uma cópia com campos alterados (usado na edição)
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