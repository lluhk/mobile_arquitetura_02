// main.dart
// Composition root — montagem do grafo de dependências.
//
// Atividade 07: a aplicação agora inicia na HomePage.
// Fluxo: HomePage → ProductListPage → ProductDetailPage
// Conforme "Múltiplas Telas - Aula 1", seção 14.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/cache/product_cache.dart';
import 'core/network/http_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/pages/product_detail_page.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/product_provider.dart';

void main() {
  final httpClient = AppHttpClient();
  final remoteDataSource = ProductRemoteDataSourceImpl(httpClient: httpClient);
  final cache = ProductCache();

  final ProductRepository productRepository = ProductRepositoryImpl(
    remoteDataSource: remoteDataSource,
    cache: cache,
  );

  final favoritesProvider = FavoritesProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            repository: productRepository,
            onProductsLoaded: favoritesProvider.setProducts,
          ),
        ),
      ],
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
      // Desafio opcional: rotas nomeadas centralizadas no MaterialApp
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/products': (context) => const ProductListPage(),
      },
      // Rota de detalhes recebe argumentos (passagem de dados entre telas)
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final product = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          );
        }
        return null;
      },
    );
  }
}
