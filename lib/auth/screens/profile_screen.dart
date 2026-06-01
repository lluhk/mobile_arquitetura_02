// auth/screens/profile_screen.dart
//
// Tela de perfil do usuário autenticado.
// (Desafio Extra — item 2: tela de perfil com endpoint /auth/me)
//
// Exibe os dados atualizados buscados em /auth/me com o token da sessão.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../session/auth_session.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final session = context.read<AuthSession>();
    final token = session.currentUser!.token;
    _profileFuture = AuthService().fetchProfile(token);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<AuthSession>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: () => setState(_loadProfile),
          ),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Fallback: exibe os dados da sessão em cache
            final user = session.currentUser!;
            return _buildProfile(context, theme, user, fromCache: true);
          }

          return _buildProfile(context, theme, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, ThemeData theme, UserModel user,
      {bool fromCache = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (fromCache)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exibindo dados em cache (falha ao buscar /auth/me).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Avatar
          CircleAvatar(
            radius: 56,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage:
                user.image.isNotEmpty ? NetworkImage(user.image) : null,
            child: user.image.isEmpty
                ? Icon(Icons.person,
                    size: 56, color: theme.colorScheme.onPrimaryContainer)
                : null,
          ),
          const SizedBox(height: 16),

          Text(
            user.fullName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Card com dados
          Card(
            child: Column(
              children: [
                _infoTile(Icons.email_outlined, 'E-mail', user.email, theme),
                const Divider(height: 1),
                _infoTile(
                    Icons.badge_outlined, 'ID', '#${user.id}', theme),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botão de logout
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthSession>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: Colors.grey.shade600)),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}
