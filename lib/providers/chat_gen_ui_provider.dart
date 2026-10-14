import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/gen_ui_response.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';
import '../services/groq_service.dart';
import 'role_provider.dart';
import 'cart_provider.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());
final groqServiceProvider = Provider((ref) => GroqService());

class ChatGenUiState {
  final bool isLoading;
  final List<GenUiResponse> messages;
  final String? errorMessage;

  ChatGenUiState({
    this.isLoading = false,
    this.messages = const [],
    this.errorMessage,
  });

  ChatGenUiState copyWith({
    bool? isLoading,
    List<GenUiResponse>? messages,
    String? errorMessage,
  }) {
    return ChatGenUiState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

class ChatGenUiNotifier extends Notifier<ChatGenUiState> {
  @override
  ChatGenUiState build() {
    return ChatGenUiState(messages: [
      GenUiResponse(
        uiType: 'text_message',
        textExplanation: 'Привіт! Напишіть, що ви шукаєте.',
      )
    ]);
  }

  DatabaseService get _dbService => ref.read(databaseServiceProvider);
  GroqService get _groqService => ref.read(groqServiceProvider);

  Future<void> sendPrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final isAdmin = ref.read(roleProvider);
      final cartItems = ref.read(cartProvider);

      final intentResult = await _groqService.parseIntent(
        userPrompt: prompt,
        isAdmin: isAdmin,
        cartHasItems: cartItems.isNotEmpty,
      );

      GenUiResponse uiResponse;

      switch (intentResult.action) {
        case 'search_products':
          final p = intentResult.parameters;
          final products = await _dbService.filterProducts(
            category: p['category'] as String?,
            brand: p['brand'] as String?,
            maxPrice: (p['max_price'] as num?)?.toDouble(),
            minPrice: (p['min_price'] as num?)?.toDouble(),
            keyword: p['keyword'] as String?,
          );
          uiResponse = GenUiResponse(
            uiType: 'product_grid',
            textExplanation: intentResult.textExplanation,
            products: products,
          );
          break;

        case 'compare_cart':
          final cartProducts = cartItems.map((e) => e.product).toList();
          uiResponse = GenUiResponse(
            uiType: 'product_comparison',
            textExplanation: intentResult.textExplanation,
            products: cartProducts,
          );
          break;

        case 'compare_category':
          final category = intentResult.parameters['category'] as String?;
          final products = await _dbService.filterProducts(category: category);
          uiResponse = GenUiResponse(
            uiType: 'product_comparison',
            textExplanation: intentResult.textExplanation,
            products: products,
          );
          break;

        case 'checkout_form':
          uiResponse = GenUiResponse(
            uiType: 'checkout_form',
            textExplanation: intentResult.textExplanation,
          );
          break;

        case 'admin_orders':
          final pendingOrders = await _dbService.getPendingOrders();
          uiResponse = GenUiResponse(
            uiType: 'admin_orders',
            textExplanation: intentResult.textExplanation,
            orders: pendingOrders,
          );
          break;

        case 'admin_chart':
          final p = intentResult.parameters;
          final isSales = p['metric'] == 'sales';
          final chartType = (p['chart_type'] as String?) ?? 'bar';
          final chartData = await _dbService.getCategoryStats(
            isSalesMetric: isSales,
            chartType: chartType,
          );
          uiResponse = GenUiResponse(
            uiType: 'admin_chart',
            textExplanation: intentResult.textExplanation,
            chartData: chartData,
          );
          break;

        case 'text_message':
        default:
          uiResponse = GenUiResponse(
            uiType: 'text_message',
            textExplanation: intentResult.textExplanation,
          );
      }

      state = state.copyWith(
        isLoading: false,
        messages: [...state.messages, uiResponse],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Помилка обробки: $e',
      );
    }
  }

  void openCheckoutForm() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      state = state.copyWith(messages: [
        ...state.messages,
        GenUiResponse(
          uiType: 'text_message',
          textExplanation: 'Ваш кошик порожній! Додайте товари перед оформленням.',
        )
      ]);
    } else {
      state = state.copyWith(messages: [
        ...state.messages,
        GenUiResponse(
          uiType: 'checkout_form',
          textExplanation: 'Форма швидкого оформлення замовлення:',
        )
      ]);
    }
  }

  Future<bool> submitOrder({
    required String name,
    required String email,
    required String password,
    required String address,
    required String paymentMethod,
  }) async {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = ref.read(cartProvider);

    if (cartItems.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    try {
      final newOrder = OrderModel(
        customerName: name,
        customerEmail: email,
        customerPassword: password,
        address: address,
        paymentMethod: paymentMethod,
        items: cartNotifier.toOrderItems(),
        totalPrice: cartNotifier.totalCartPrice,
        orderDate: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        status: 'Очікує',
      );

      await _dbService.createOrder(newOrder);
      cartNotifier.clearCart();

      state = state.copyWith(
        isLoading: false,
        messages: [
          ...state.messages,
          GenUiResponse(
            uiType: 'text_message',
            textExplanation: '✅ Замовлення успішно оформлено! Дякуємо за покупку.',
          )
        ],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Не вдалося оформити замовлення: $e',
      );
      return false;
    }
  }

  Future<void> completeOrder(int orderId) async {
    await _dbService.updateOrderStatus(orderId, 'Виконане');
    final updatedOrders = await _dbService.getPendingOrders();

    state = state.copyWith(
      messages: [
        ...state.messages,
        GenUiResponse(
          uiType: 'admin_orders',
          textExplanation: 'Замовлення #$orderId позначено як виконане! Оновлений список:',
          orders: updatedOrders,
        )
      ],
    );
  }
}

final chatGenUiProvider = NotifierProvider<ChatGenUiNotifier, ChatGenUiState>(ChatGenUiNotifier.new);