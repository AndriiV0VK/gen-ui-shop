import 'dart:convert';
import 'product_model.dart';
import 'order_model.dart';

class ChartData {
  final String title;
  final String chartType;
  final List<String> labels;
  final List<double> values;

  ChartData({
    required this.title,
    required this.chartType,
    required this.labels,
    required this.values,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      title: map['title'] as String? ?? 'Аналітика',
      chartType: (map['chart_type'] as String? ?? 'bar').toLowerCase(),
      labels: (map['labels'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      values: (map['values'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class GenUiResponse {

  final String uiType;
  final String textExplanation;
  final List<Product> products;
  final List<OrderModel> orders;
  final ChartData? chartData;

  GenUiResponse({
    required this.uiType,
    required this.textExplanation,
    this.products = const [],
    this.orders = const [],
    this.chartData,
  });

  factory GenUiResponse.fromJsonString(
    String jsonString, {
    required List<Product> allProductsInDb,
    required List<OrderModel> allOrdersInDb,
  }) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      final String uiType = parsed['ui_type'] ?? 'text_message';
      final String textExplanation = parsed['text_explanation'] ?? '';
      final Map<String, dynamic> data = parsed['data'] as Map<String, dynamic>? ?? {};

      List<Product> resolvedProducts = [];
      List<OrderModel> resolvedOrders = [];
      ChartData? resolvedChart;

      if (uiType == 'product_grid' || uiType == 'product_comparison') {
        final List<dynamic> productIds = data['product_ids'] ?? [];
        if (productIds.isNotEmpty) {
          resolvedProducts = allProductsInDb
              .where((p) => productIds.contains(p.id))
              .toList();
        } else if (data['products'] != null) {
          final List<dynamic> rawList = data['products'];
          resolvedProducts = allProductsInDb.where((p) {
            return rawList.any((item) {
              if (item is Map) return item['id'] == p.id || item['name'] == p.name;
              if (item is String) return p.name.toLowerCase().contains(item.toLowerCase());
              return false;
            });
          }).toList();
        }
      }

      if (uiType == 'admin_orders') {
        final List<dynamic> orderIds = data['order_ids'] ?? [];
        final parsedIds = orderIds
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toList();

        if (parsedIds.isNotEmpty) {
          resolvedOrders = allOrdersInDb.where((o) => parsedIds.contains(o.id)).toList();
        }

        if (resolvedOrders.isEmpty) {
          resolvedOrders = allOrdersInDb.where((o) => o.status == 'Очікує').toList();
        }
      }

      if (uiType == 'admin_chart') {
        resolvedChart = ChartData.fromMap(data);
      }

      return GenUiResponse(
        uiType: uiType,
        textExplanation: textExplanation,
        products: resolvedProducts,
        orders: resolvedOrders,
        chartData: resolvedChart,
      );
    } catch (e) {
      return GenUiResponse(
        uiType: 'text_message',
        textExplanation: jsonString,
      );
    }
  }

  factory GenUiResponse.fallback(String message) {
    return GenUiResponse(
      uiType: 'text_message',
      textExplanation: message,
    );
  }
}