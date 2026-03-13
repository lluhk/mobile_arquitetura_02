// presentation/widgets/cache_banner.dart
// Banner informativo exibido quando os dados vêm do cache (modo offline).

import 'package:flutter/material.dart';

class CacheBanner extends StatelessWidget {
  final String? age;
  final VoidCallback onRefresh;

  const CacheBanner({super.key, this.age, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: Colors.amber.shade100,
      leading: Icon(Icons.wifi_off_rounded, color: Colors.amber.shade800),
      content: Text(
        age != null
            ? 'Sem conexão. Exibindo dados salvos $age.'
            : 'Sem conexão. Exibindo dados do cache.',
        style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: onRefresh,
          child: Text('Tentar novamente',
              style: TextStyle(color: Colors.amber.shade900)),
        ),
      ],
    );
  }
}
