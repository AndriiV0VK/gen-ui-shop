import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

class AiIntentResult {
  final String action; // 'search_products' | 'compare_cart' | 'compare_category' | 'checkout_form' | 'admin_orders' | 'admin_chart' | 'text_message'
  final String textExplanation;
  final Map<String, dynamic> parameters;

  AiIntentResult({
    required this.action,
    required this.textExplanation,
    this.parameters = const {},
  });

  factory AiIntentResult.fromJson(Map<String, dynamic> json) {
    return AiIntentResult(
      action: json['action'] as String? ?? 'text_message',
      textExplanation: json['text_explanation'] as String? ?? '',
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  factory AiIntentResult.fallback(String message) {
    return AiIntentResult(
      action: 'text_message',
      textExplanation: message,
    );
  }
}

class GroqService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.groqApiUrl,
      headers: {
        'Authorization': 'Bearer ${ApiConstants.groqApiKey}',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<AiIntentResult> parseIntent({
    required String userPrompt,
    required bool isAdmin,
    required bool cartHasItems,
  }) async {
    final systemPrompt = '''
Ти — NLU-маршрутизатор (Intent Parser) для магазину техніки.
Поточна роль: ${isAdmin ? "АДМІНІСТРАТОР" : "КЛІЄНТ"}.
У кошику зараз є товари: ${cartHasItems ? "ТАК" : "НІ"}.

Твоя задача — визначити намір користувача та сформувати фільтри для запиту в базу даних SQLite.
Категорії магазину: "Смартфони", "Ноутбуки", "Телевізори", "Комплектуючі".

${!isAdmin ? "ПРАВИЛО БЕЗПЕКИ: Клієнт НЕ має доступу до аналітики, діаграм та замовлень інших клієнтів. Якщо він це просить — action: 'text_message' з відмовою." : ""}

ЗАВЖДИ відповідай JSON у форматі:
{
  "action": "search_products | compare_cart | compare_category | checkout_form | admin_orders | admin_chart | text_message",
  "text_explanation": "Короткий текст користувачеві",
  "parameters": { ... }
}

СПИСОК ACTIONS ТА ПАРАМЕТРІВ:
1. Пошук товарів (наприклад: "покажи смартфони Samsung до 30000"):
   action: "search_products",
   parameters: {
     "category": "Смартфони" (або інша категорія, якщо вказана),
     "brand": "Samsung" (якщо згадано бренд),
     "max_price": 30000.0 (число, якщо вказано "до/дешевше"),
     "min_price": 0.0 (число, якщо вказано "від/дорожче"),
     "keyword": "" (якщо є специфічне слово, наприклад "геймерський", "4k")
   }

2. Порівняння товарів з кошика (наприклад: "порівняй товари в кошику"):
   action: "compare_cart", parameters: {}

3. Порівняння в категорії (наприклад: "порівняй телевізори"):
   action: "compare_category", parameters: { "category": "Телевізори" }

4. Оформлення замовлення ("купити", "оформити", "перейти до оплати"):
   action: "checkout_form", parameters: {}

5. (Тільки Адмін) Неопрацьовані замовлення ("покажи замовлення які очікують"):
   action: "admin_orders", parameters: {}

6. (Тільки Адмін) Графіки та діаграми ("діаграма залишків", "кругова діаграма продажів"):
   action: "admin_chart",
   parameters: {
     "chart_type": "bar" або "pie",
     "metric": "stock" (якщо про залишки) або "sales" (якщо про продажі/куплені)
   }

7. Усі інші загальні фрази:
   action: "text_message", parameters: {}
''';

    try {
      final response = await _dio.post(
        '',
        data: {
          'model': ApiConstants.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.1,
          'response_format': {'type': 'json_object'},
        },
      );

      final content = response.data['choices'][0]['message']['content'] as String;
      return AiIntentResult.fromJson(jsonDecode(content));
    } catch (e) {
      return AiIntentResult.fallback('Не вдалося обробити запит: $e');
    }
  }
}