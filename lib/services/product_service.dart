// services/product_service.dart
//
// Centraliza todas as chamadas HTTP da API de produtos.
// Implementa as quatro operações do CRUD:
//   GET    /products        → fetchProducts()
//   POST   /products/add    → addProduct()
//   PUT    /products/:id    → updateProduct()
//   DELETE /products/:id    → deleteProduct()
//
// CORREÇÃO: migrado de fakestoreapi.com para dummyjson.com,
// que possui CORS configurado corretamente para Flutter Web.
//
// Nota: dummyjson é uma API de teste — POST, PUT e DELETE
// retornam respostas simuladas sem persistência real no servidor.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const _baseUrl = 'https://dummyjson.com/products';

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  // ── READ ──────────────────────────────────────────────────────────────────

  /// Busca todos os produtos (GET /products).
  /// dummyjson retorna { "products": [...], "total": 194, "skip": 0, "limit": 30 }
  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl?limit=30'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List list = data['products'] as List;
      return list.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Erro ao buscar produtos: ${response.statusCode}');
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  /// Cria um novo produto (POST /products/add).
  Future<Product> addProduct(Product product) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    }
    throw Exception('Erro ao criar produto: ${response.statusCode}');
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  /// Atualiza um produto existente (PUT /products/:id).
  Future<Product> updateProduct(Product product) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl/${product.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    }
    throw Exception('Erro ao atualizar produto: ${response.statusCode}');
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  /// Remove um produto (DELETE /products/:id).
  Future<void> deleteProduct(int id) async {
    final response = await _client
        .delete(Uri.parse('$_baseUrl/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar produto: ${response.statusCode}');
    }
  }
}