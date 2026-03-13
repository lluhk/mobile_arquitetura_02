// data/models/product_model.dart
// Modelo de dados responsável por deserializar o JSON da API
// e converter para a entidade de domínio Product.

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.ratingRate,
    required super.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      ratingRate: (rating['rate'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (rating['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converte o modelo para a entidade pura de domínio.
  Product toEntity() => Product(
        id: id,
        title: title,
        price: price,
        description: description,
        category: category,
        imageUrl: imageUrl,
        ratingRate: ratingRate,
        ratingCount: ratingCount,
      );
}
