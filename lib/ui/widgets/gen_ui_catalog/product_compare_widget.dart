import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../components/app_card.dart';
import '../components/app_section_header.dart';
import '../components/app_price_text.dart';
import '../components/app_rating_badge.dart';
import '../components/app_alert_banner.dart';

class ProductCompareWidget extends StatelessWidget {
  final List<Product> products;

  const ProductCompareWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const AppAlertBanner(
        message: 'Немає товарів для порівняння.',
        type: AlertType.info,
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Порівняння товарів',
            icon: Icons.compare_arrows,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Параметр', style: TextStyle(fontWeight: FontWeight.bold))),
                ...products.map((p) => DataColumn(
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Ціна')),
                  ...products.map((p) => DataCell(AppPriceText(price: p.price, fontSize: 13))),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Бренд')),
                  ...products.map((p) => DataCell(Text(p.brand))),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Оцінка')),
                  ...products.map((p) => DataCell(AppRatingBadge(rating: p.rating))),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Залишок')),
                  ...products.map((p) => DataCell(Text('${p.totalStock} шт.'))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}