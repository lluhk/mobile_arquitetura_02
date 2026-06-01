// main.dart
// Atividade 12 — Autenticação e Troca de API
//
// Fluxo geral:
//   1. Inicializa AuthSession (carrega sessão salva com shared_preferences)
//   2. SplashScreen verifica sessão → /login ou /products
//   3. /login     → LoginScreen   (pública)
//   4. /products  → ProductListScreen (protegida, exige sessão)
//   5. /products/:id → ProductDetailScreen (protegida, exige sessão)
//   6. /profile   → ProfileScreen (protegida, exibe /auth/me)
//
// API utilizada: https://dummyjson.com

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/session/auth_session.dart';
import 'auth/screens/splash_screen.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/profile_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'models/product.dart';
import 'services/product_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega sessão persistida antes de montar a árvore de widgets
  final authSession = AuthSession();
  await authSession.init();

  runApp(
    ChangeNotifierProvider.value(
      value: authSession,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DummyShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/products': (context) => const _AuthGuard(child: ProductListScreen()),
        '/profile': (context) => const _AuthGuard(child: ProfileScreen()),
      },
      onGenerateRoute: (settings) {
        // Rota /products/:id  — Requisito 11
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null &&
            uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'products') {
          final idStr = uri.pathSegments[1];
          final id = int.tryParse(idStr);
          if (id != null) {
            // Pode receber Product pronto como argumento (otimista)
            // ou buscar via fetchById se vier apenas o id.
            final product = settings.arguments is Product
                ? settings.arguments as Product
                : null;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => _AuthGuard(
                child: ProductDetailScreen(
                  product: product ?? Product(
                    id: id,
                    title: '',
                    price: 0,
                    description: '',
                    category: '',
                    image: '',
                  ),
                ),
              ),
            );
          }
        }

        // Rota legada /details (mantida por compatibilidade)
        if (settings.name == '/details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => _AuthGuard(child: ProductDetailScreen(product: product)),
          );
        }

        return null;
      },
    );
  }
}

/// Guard que protege rotas autenticadas.
/// Usa [Consumer] para reagir reativamente ao estado da sessão,
/// garantindo que a verificação acontece após o [AuthSession.init()].
class _AuthGuard extends StatelessWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthSession>(
      builder: (context, session, _) {
        if (!session.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }
}
