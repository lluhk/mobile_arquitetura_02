// presentation/widgets/error_view.dart
// Widget reutilizável para exibir estados de erro com ação de retry.

import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';

class ErrorView extends StatelessWidget {
  final AppError? error;
  final String? message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    this.error,
    this.message,
    required this.onRetry,
  });

  IconData get _icon => switch (error) {
        NetworkError() => Icons.wifi_off_rounded,
        ServerError() => Icons.cloud_off_rounded,
        ParseError() => Icons.data_object_rounded,
        _ => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 72, color: theme.colorScheme.error),
            const SizedBox(height: 20),
            Text(
              message ?? error?.message ?? 'Ocorreu um erro.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
