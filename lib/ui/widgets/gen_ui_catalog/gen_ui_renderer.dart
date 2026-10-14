import 'package:flutter/material.dart';
import '../../../models/gen_ui_response.dart';
import '../components/app_card.dart';
import 'product_grid_widget.dart';
import 'product_compare_widget.dart';
import 'checkout_form_widget.dart';
import 'admin_orders_widget.dart';
import 'admin_chart_widget.dart';

class GenUiRenderer extends StatelessWidget {
  final GenUiResponse response;

  const GenUiRenderer({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (response.textExplanation.isNotEmpty)
            AppCard(
              color: Colors.blueGrey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                response.textExplanation,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          const SizedBox(height: 4),
          _buildComponent(),
        ],
      ),
    );
  }

  Widget _buildComponent() {
    switch (response.uiType) {
      case 'product_grid':
        return ProductGridWidget(products: response.products);
      case 'product_comparison':
        return ProductCompareWidget(products: response.products);
      case 'checkout_form':
        return const CheckoutFormWidget();
      case 'admin_orders':
        return AdminOrdersWidget(orders: response.orders);
      case 'admin_chart':
        return AdminChartWidget(chartData: response.chartData);
      case 'text_message':
      default:
        return const SizedBox.shrink();
    }
  }
}