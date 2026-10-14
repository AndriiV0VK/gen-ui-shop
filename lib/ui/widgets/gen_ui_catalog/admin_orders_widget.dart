import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_model.dart';
import '../../../providers/chat_gen_ui_provider.dart';
import '../components/app_card.dart';
import '../components/app_section_header.dart';
import '../components/app_price_text.dart';
import '../components/app_status_chip.dart';
import '../components/app_alert_banner.dart';

class AdminOrdersWidget extends ConsumerWidget {
  final List<OrderModel> orders;

  const AdminOrdersWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const AppAlertBanner(
        message: 'Усі замовлення опрацьовані! Немає незавершених задач.',
        type: AlertType.success,
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Неопрацьовані замовлення (${orders.length})',
            icon: Icons.admin_panel_settings,
            iconColor: Colors.deepPurple,
          ),
          const Divider(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${order.id} • ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      AppStatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppPriceText(price: order.totalPrice, fontSize: 14),
                      Text(order.orderDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Адреса: ${order.address}', style: const TextStyle(fontSize: 12)),
                  Text(
                    'Товари: ${order.items.map((i) => "${i.productName} (x${i.quantity})").join(", ")}',
                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Позначити виконаним', style: TextStyle(fontSize: 12)),
                      onPressed: () => ref.read(chatGenUiProvider.notifier).completeOrder(order.id!),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}