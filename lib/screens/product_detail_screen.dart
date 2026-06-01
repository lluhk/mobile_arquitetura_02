// screens/product_detail_screen.dart
//
// Tela de detalhes do produto.
// Recebe o Product como argumento inicial e chama GET /products/{id}
// para buscar os dados atualizados da API. (Requisito 11)

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_form_screen.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final id = widget.product.id;
    if (id != null && id <= 194) {
      // ID real — busca dados atualizados via GET /products/{id}
      _productFuture = ProductService().fetchById(id);
    } else {
      // ID local (produto criado pelo usuário) — usa o objeto da lista
      _productFuture = Future.value(widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.product.category,
                style: const TextStyle(fontSize: 14))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // Fallback: exibe os dados que já vieram da lista
          return _buildScaffold(context, widget.product);
        }

        return _buildScaffold(context, snapshot.data!);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.category, style: const TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () async {
              final updated = await Navigator.push<Product>(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product),
                ),
              );
              if (updated != null && context.mounted) {
                try {
                  await ProductService().updateProduct(updated);
                  if (context.mounted) Navigator.pop(context, updated);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Erro ao atualizar produto.')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              height: 260,
              padding: const EdgeInsets.all(24),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(product.category),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Voltar à lista'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}