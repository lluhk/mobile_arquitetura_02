// main.dart
// Composition root — montagem do grafo de dependências.
//
// Atividade 09: adicionada a rota '/crud' apontando para o ProductListScreen,
// que implementa o CRUD completo com a FakeStore API.

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
import 'screens/product_list_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/products': (context) => const ProductListPage(),
        '/crud': (context) => const ProductListScreen(), // Atividade 09
      },
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
