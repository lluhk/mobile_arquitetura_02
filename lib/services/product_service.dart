// services/product_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const _baseUrl = 'https://dummyjson.com/products';
  static const _maxRealId = 194;

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  // ── READ ALL ──────────────────────────────────────────────────────────────

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

  // ── READ ONE ──────────────────────────────────────────────────────────────

  Future<Product> fetchById(int id) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Produto não encontrado: ${response.statusCode}');
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<Product> addProduct(Product product) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao criar produto: ${response.statusCode}');
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  /// Envia o PUT para IDs reais mas sempre devolve o próprio [product],
  /// ignorando a resposta da API — a DummyJSON retorna campos inconsistentes
  /// no PUT que quebram o fromJson (ex: price nulo, thumbnail ausente).
  Future<Product> updateProduct(Product product) async {
    final id = product.id;

    if (id != null && id <= _maxRealId) {
      // Dispara o PUT apenas para registrar na API, mas ignora a resposta
      await _client
          .put(
            Uri.parse('$_baseUrl/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(product.toJson()),
          )
          .timeout(const Duration(seconds: 15));
    }

    // Sempre retorna o produto local com os dados que o usuário digitou
    return product;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> deleteProduct(int id) async {
    if (id > _maxRealId) return;

    final response = await _client
        .delete(Uri.parse('$_baseUrl/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar produto: ${response.statusCode}');
    }
  }
}