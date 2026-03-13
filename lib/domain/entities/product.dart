// domain/entities/product.dart
// Entidade de domínio — representa um produto sem detalhes de infraestrutura

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double ratingRate;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.ratingRate,
    required this.ratingCount,
  });
}
