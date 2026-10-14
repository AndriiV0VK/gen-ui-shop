import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addToCart(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      final updatedList = List<CartItem>.from(state);
      updatedList[existingIndex].quantity += 1;
      state = updatedList;
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalCartPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  List<OrderItem> toOrderItems() {
    return state
        .map((item) => OrderItem(
              productId: item.product.id!,
              productName: item.product.name,
              price: item.product.price,
              quantity: item.quantity,
            ))
        .toList();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);