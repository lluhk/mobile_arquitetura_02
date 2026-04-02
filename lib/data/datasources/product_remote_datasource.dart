// data/datasources/product_remote_datasource.dart
// DataSource remoto — responsável exclusivamente por buscar dados da API.
//
// CORREÇÃO: migrado de fakestoreapi.com para dummyjson.com,
// que possui CORS configurado corretamente para Flutter Web.

import '../../core/errors/app_error.dart';
import '../../core/network/http_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  // dummyjson.com: API estável com CORS habilitado para Web
  static const _baseUrl = 'https://dummyjson.com';

  final AppHttpClient _httpClient;

  ProductRemoteDataSourceImpl({required AppHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final data = await _httpClient.get('$_baseUrl/products?limit=30');

      // dummyjson retorna { "products": [...], "total": ..., ... }
      if (data is! Map<String, dynamic>) throw const ParseError();
      final list = data['products'];
      if (list is! List) throw const ParseError();

      return list
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AppError {
      rethrow;
    } catch (e) {
      throw ParseError('Erro ao converter produtos: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    try {
      final data = await _httpClient.get('$_baseUrl/products/$id');
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on AppError {
      rethrow;
    } catch (e) {
      throw ParseError('Erro ao converter produto: $e');
    }
  }
}