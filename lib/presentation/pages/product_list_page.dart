// presentation/pages/product_list_page.dart
// Tela principal: lista de produtos com botão de favorito em cada item.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/cache_banner.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'favorites_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Produtos'),
        centerTitle: false,
        actions: [
          // Botão de favoritos com contador (Atividade 05)
          Consumer<FavoritesProvider>(
            builder: (_, fav, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border_rounded),
                  tooltip: 'Meus favoritos',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FavoritesPage()),
                  ),
                ),
                if (fav.favoriteCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text('${fav.favoriteCount}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          ),
          Consumer<ProductProvider>(
            builder: (_, provider, __) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Forçar atualização',
              onPressed: provider.status == ProductStatus.loading
                  ? null
                  : () => provider.fetchProducts(forceRefresh: true),
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.status == ProductStatus.loading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando produtos...'),
                ],
              ),
            );
          }

          if (provider.status == ProductStatus.error) {
            return ErrorView(
              error: provider.error,
              message: provider.errorMessage,
              onRetry: () => provider.fetchProducts(),
            );
          }

          return Column(
            children: [
              if (provider.status == ProductStatus.stale)
                CacheBanner(
                  age: provider.cacheAge,
                  onRefresh: () =>
                      provider.fetchProducts(forceRefresh: true),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      provider.fetchProducts(forceRefresh: true),
                  child: Consumer<FavoritesProvider>(
                    builder: (context, fav, _) => ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.products.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        final originalIndex = fav.allProducts
                            .indexWhere((p) => p.id == product.id);
                        return ProductCard(
                          product: product,
                          isFavorite: product.favorite,
                          onFavoriteToggle: () =>
                              fav.toggleFavorite(originalIndex),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
