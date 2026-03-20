// domain/entities/product.dart
// Entidade de domínio — representa um produto da FakeStore API.
// O campo [favorite] é mutável pois representa uma preferência local do usuário,
// não um dado vindo da API.

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double ratingRate;
  final int ratingCount;
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.ratingRate,
    required this.ratingCount,
    this.favorite = false,
  });
}
