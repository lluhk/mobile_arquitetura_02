// presentation/pages/favorites_page.dart
//
// Tela de favoritos — Atividade 05.
// Usa os produtos reais carregados da FakeStore API.
// O estado de favorito é gerenciado pelo FavoritesProvider (Provider).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final displayed = fav.displayed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos — Provider'),
        centerTitle: false,
        actions: [
          // Desafio opcional: contador + filtro
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: fav.showFavoritesOnly
                    ? 'Mostrar todos'
                    : 'Mostrar favoritos',
                icon: Icon(fav.showFavoritesOnly
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined),
                onPressed: () =>
                    context.read<FavoritesProvider>().toggleFilter(),
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
        ],
      ),
      body: !fav.hasProducts
          ? const Center(child: Text('Carregue os produtos primeiro.'))
          : displayed.isEmpty
              ? const Center(child: Text('Nenhum favorito ainda.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, listIndex) {
                    final product = displayed[listIndex];
                    final originalIndex = fav.allProducts
                        .indexWhere((p) => p.id == product.id);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        // Desafio opcional: destaque visual
                        color: product.favorite
                            ? Colors.amber.shade50
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: product.favorite
                              ? Colors.amber.shade300
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: product),
                          ),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(
                                width: 56,
                                height: 56,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined),
                          ),
                        ),
                        title: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: product.favorite
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13),
                        ),
                        subtitle: Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            product.favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: product.favorite
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () => context
                              .read<FavoritesProvider>()
                              .toggleFavorite(originalIndex),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
