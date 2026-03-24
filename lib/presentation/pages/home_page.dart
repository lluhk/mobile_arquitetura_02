// presentation/pages/home_page.dart
//
// Tela inicial — ponto de entrada da aplicação.
// Conforme "Múltiplas Telas - Aula 1" (seção 14.6):
// contém título, descrição e botão para acessar os produtos.
//
// Navegação feita com Navigator.push() + MaterialPageRoute (padrão)
// e também com pushNamed() usando rotas nomeadas (desafio opcional).

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
              Icon(
                Icons.storefront_rounded,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                'FakeStore',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Descrição
              Text(
                'Explore nossa seleção de produtos com os melhores preços. '
                'Clique abaixo para ver o catálogo completo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Botão principal — Navigator.push() (desafio: pushNamed)
              FilledButton.icon(
                onPressed: () {
                  // Desafio opcional: rota nomeada
                  Navigator.pushNamed(context, '/products');
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Ver Produtos'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
