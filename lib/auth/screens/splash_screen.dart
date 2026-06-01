// auth/screens/splash_screen.dart
//
// Tela inicial que verifica se já existe sessão ativa.
// (Desafio Extra — item 4)
//
// Fluxo:
//   - Sessão ativa → navega para /products
//   - Sem sessão   → navega para /login

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../session/auth_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pequeno delay para exibir o splash antes de redirecionar
    Future.delayed(const Duration(milliseconds: 800), _redirect);
  }

  void _redirect() {
    if (!mounted) return;
    final session = context.read<AuthSession>();
    Navigator.pushReplacementNamed(
      context,
      session.isLoggedIn ? '/products' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 96,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'DummyShop',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
