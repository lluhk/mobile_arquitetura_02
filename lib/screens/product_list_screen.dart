// screens/product_list_screen.dart
//
// Tela de listagem dos produtos com CRUD completo.
// Usa FutureBuilder para o carregamento inicial e setState para
// refletir as operações de criação, edição e exclusão em tempo real.

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_list_tile.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _productsFuture;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = _service.fetchProducts().then((list) {
      setState(() => _products = list);
      return list;
    });
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<void> _navigateToCreate() async {
    final newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );

    if (newProduct != null) {
      try {
        final created = await _service.addProduct(newProduct);
        setState(() => _products.insert(0, created));
        _showSnackBar('Produto criado com sucesso!', Colors.green);
      } catch (e) {
        _showSnackBar('Erro ao criar produto.', Colors.red);
      }
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  Future<void> _navigateToEdit(Product product) async {
    final updated = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );

    if (updated != null) {
      try {
        final result = await _service.updateProduct(updated);
        setState(() {
          final index = _products.indexWhere((p) => p.id == result.id);
          if (index != -1) _products[index] = result;
        });
        _showSnackBar('Produto atualizado!', Colors.blue);
      } catch (e) {
        _showSnackBar('Erro ao atualizar produto.', Colors.red);
      }
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text(
            'Deseja excluir "${product.title}"?\nEssa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteProduct(product.id!);
        setState(() => _products.removeWhere((p) => p.id == product.id));
        _showSnackBar('Produto excluído.', Colors.orange);
      } catch (e) {
        _showSnackBar('Erro ao excluir produto.', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recarregar',
            onPressed: () => setState(_loadProducts),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          // Estado: carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          // Estado: erro
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar produtos.\n${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => setState(_loadProducts),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // Estado: lista vazia
          if (_products.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          // Estado: lista carregada
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return ProductListTile(
                product: product,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(product: product),
                  ),
                ),
                onEdit: () => _navigateToEdit(product),
                onDelete: () => _confirmDelete(product),
              );
            },
          );
        },
      ),
      // FAB para criar novo produto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Produto'),
      ),
    );
  }
}
