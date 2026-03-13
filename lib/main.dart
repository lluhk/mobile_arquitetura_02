// main.dart
// Composition root — montagem do grafo de dependências.
//
// COMO A ARQUITETURA FACILITA TROCAR A API POR UM BANCO LOCAL?
// Basta criar uma nova implementação de ProductRepository (ex: LocalProductRepository)
// que usa SQLite ou Hive, e substituir aqui no main.dart.
// Nenhum arquivo de domain, presentation ou core precisa ser alterado —
// apenas esta linha de montagem muda.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/cache/product_cache.dart';
import 'core/network/http_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/providers/product_provider.dart';

void main() {
  final httpClient = AppHttpClient();
  final remoteDataSource = ProductRemoteDataSourceImpl(httpClient: httpClient);
  final cache = ProductCache();

  final ProductRepository productRepository = ProductRepositoryImpl(
    remoteDataSource: remoteDataSource,
    cache: cache,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(repository: productRepository),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FakeStore App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ProductListPage(),
    );
  }
}
