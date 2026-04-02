// presentation/pages/home_page.dart
// Tela inicial — ponto de entrada da aplicação.

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.storefront_rounded,
                  size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'FakeStore',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Explore e gerencie produtos da FakeStore API.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Listagem (somente leitura + favoritos)
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/products'),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Ver Produtos'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),

              // CRUD completo (Atividade 09)
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/crud'),
                icon: const Icon(Icons.manage_search_rounded),
                label: const Text('Gerenciar Produtos (CRUD)'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
