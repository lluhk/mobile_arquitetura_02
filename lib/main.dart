// main.dart
// Atividade 12 — Autenticação e Troca de API
//
// Fluxo geral:
//   1. Inicializa AuthSession (carrega sessão salva com shared_preferences)
//   2. SplashScreen verifica sessão → /login ou /products
//   3. /login  → LoginScreen   (pública)
//   4. /products → ProductListScreen (protegida, exige sessão)
//   5. /profile  → ProfileScreen (protegida, exibe /auth/me)
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
      // Inicia pelo splash que decide para onde ir
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/products': (context) => _authGuard(context, const ProductListScreen()),
        '/profile': (context) => _authGuard(context, const ProfileScreen()),
      },
      onGenerateRoute: (settings) {
        // Rota de detalhes recebe Product como argumento
        if (settings.name == '/details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }

  /// Guard simples: se não há sessão ativa, redireciona para /login.
  Widget _authGuard(BuildContext context, Widget child) {
    final session = context.read<AuthSession>();
    if (!session.isLoggedIn) {
      // Agenda o redirecionamento após o frame atual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}
