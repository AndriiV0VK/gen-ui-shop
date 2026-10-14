import 'dart:convert';

class OrderItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    productId: map['product_id'] as int,
    productName: map['product_name'] as String,
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'] as int,
  );
}

class OrderModel {
  final int? id;
  final String customerName;
  final String customerEmail;
  final String customerPassword;
  final String address;
  final String paymentMethod;
  final List<OrderItem> items;
  final double totalPrice;
  final String orderDate;
  final String status; 

  OrderModel({
    this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPassword,
    required this.address,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'Очікує',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_password': customerPassword,
      'address': address,
      'payment_method': paymentMethod,
      'items_json': jsonEncode(items.map((i) => i.toMap()).toList()),
      'total_price': totalPrice,
      'order_date': orderDate,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final itemsList = (jsonDecode(map['items_json'] as String) as List)
        .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      customerEmail: map['customer_email'] as String,
      customerPassword: map['customer_password'] as String,
      address: map['address'] as String,
      paymentMethod: map['payment_method'] as String,
      items: itemsList,
      totalPrice: (map['total_price'] as num).toDouble(),
      orderDate: map['order_date'] as String,
      status: map['status'] as String,
    );
  }
}