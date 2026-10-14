import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';
import '../components/app_card.dart';
import '../components/app_price_text.dart';
import '../components/app_rating_badge.dart';
import '../components/app_alert_banner.dart';

class ProductGridWidget extends ConsumerWidget {
  final List<Product> products;

  const ProductGridWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const AppAlertBanner(
        message: 'Товарів за вашим запитом не знайдено.',
        type: AlertType.info,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return AppCard(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppRatingBadge(rating: product.rating),
                  Text('Залишок: ${product.totalStock}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              AppPriceText(price: product.price),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showDetailsModal(context, product),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} додано в кошик!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('В кошик', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Смартфони': return Icons.phone_android;
      case 'Ноутбуки': return Icons.laptop;
      case 'Телевізори': return Icons.tv;
      case 'Комплектуючі': return Icons.memory;
      default: return Icons.devices;
    }
  }

  void _showDetailsModal(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Бренд: ${product.brand} | Категорія: ${product.category}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 20),
            Text(product.description),
            const SizedBox(height: 12),
            Text('Куплено покупцями: ${product.boughtCount} разів', style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}