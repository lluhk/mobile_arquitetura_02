// presentation/pages/product_list_page.dart
//
// Tela principal: lista de produtos.
//
// O QUE ACONTECERIA SE A UI ACESSASSE O DATASOURCE DIRETAMENTE?
// A UI ficaria acoplada a detalhes de infraestrutura (URL da API, parsing de JSON,
// timeouts). Qualquer mudança na API quebraria a tela. Além disso, seria impossível
// reutilizar a lógica de cache ou trocar a fonte de dados sem mexer na UI.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cache_banner.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

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
          // ── Estado: carregando ──────────────────────────────────────────
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

          // ── Estado: erro sem dados ──────────────────────────────────────
          if (provider.status == ProductStatus.error) {
            return ErrorView(
              error: provider.error,
              message: provider.errorMessage,
              onRetry: () => provider.fetchProducts(),
            );
          }

          // ── Estado: loaded ou stale (com ou sem cache) ──────────────────
          return Column(
            children: [
              // Banner de aviso quando dados vêm do cache (estado stale)
              if (provider.status == ProductStatus.stale)
                CacheBanner(
                  age: provider.cacheAge,
                  onRefresh: () => provider.fetchProducts(forceRefresh: true),
                ),

              // Lista de produtos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(forceRefresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        product: product,
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
            ],
          );
        },
      ),
    );
  }
}
