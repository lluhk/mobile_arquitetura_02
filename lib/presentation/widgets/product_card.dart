// presentation/widgets/product_card.dart
// Widget reutilizável para exibir um item de produto na lista.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do produto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined,
                        color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Informações textuais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    _CategoryChip(label: product.category),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _RatingBadge(
                          rate: product.ratingRate,
                          count: product.ratingCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rate;
  final int count;
  const _RatingBadge({required this.rate, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star_rounded,
            size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 2),
        Text(
          '$rate ($count)',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
