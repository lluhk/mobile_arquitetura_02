// data/models/product_model.dart
// Modelo de dados responsável por deserializar o JSON da API
// e converter para a entidade de domínio Product.
//
// CORREÇÃO: ajustado para o schema da dummyjson.com.
// Diferenças do schema em relação à fakestoreapi:
//   - "image"       → "thumbnail"
//   - "rating"      → objeto com "rate" e "count"  (dummyjson usa apenas "rating" numérico)
//   - "ratingCount" → "stock" (não existe equivalente direto; usamos 0 como fallback)

import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double ratingRate;
  final int ratingCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.ratingRate,
    required this.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      // dummyjson usa "thumbnail" como campo de imagem principal
      imageUrl: json['thumbnail'] as String? ?? json['image'] as String? ?? '',
      // dummyjson usa "rating" como double direto (ex: 4.5), não objeto
      ratingRate: (json['rating'] as num?)?.toDouble() ?? 0.0,
      // dummyjson tem "stock"; usamos como substituto do count
      ratingCount: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

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