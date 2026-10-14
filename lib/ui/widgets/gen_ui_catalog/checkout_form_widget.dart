import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/chat_gen_ui_provider.dart';
import '../components/app_text_field.dart';
import '../components/app_dropdown.dart';
import '../components/app_button.dart';

class CheckoutFormWidget extends ConsumerStatefulWidget {
  const CheckoutFormWidget({super.key});

  @override
  ConsumerState<CheckoutFormWidget> createState() => _CheckoutFormWidgetState();
}

class _CheckoutFormWidgetState extends ConsumerState<CheckoutFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Картка онлайн';

  final List<String> _paymentMethods = [
    'Картка онлайн',
    'Оплата при отриманні',
    'IBAN переказ',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).totalCartPrice;
    final currencyFormat = NumberFormat.currency(locale: 'uk_UA', symbol: 'грн', decimalDigits: 0);

    if (cart.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart_outlined, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(child: Text('Кошик порожній! Спочатку додайте товари до кошика.')),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Оформлення', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(currencyFormat.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const Divider(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Ім\'я та Прізвище',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Введіть ім\'я' : null,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                label: 'Електронна пошта',
                prefixIcon: Icons.email_outlined,
                validator: (val) => val == null || !val.contains('@') ? 'Введіть коректний email' : null,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                label: 'Пароль кабінету',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (val) => val == null || val.length < 4 ? 'Мінімум 4 символи' : null,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _addressController,
                label: 'Адреса доставки',
                prefixIcon: Icons.local_shipping_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Вкажіть адресу' : null,
              ),
              const SizedBox(height: 8),
              AppDropdown<String>(
                label: 'Форма оплати',
                prefixIcon: Icons.payment,
                value: _selectedPaymentMethod,
                items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPaymentMethod = val);
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                text: 'Підтвердити замовлення',
                color: Colors.green.shade600,
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref.read(chatGenUiProvider.notifier).submitOrder(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          address: _addressController.text.trim(),
                          paymentMethod: _selectedPaymentMethod,
                        );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}