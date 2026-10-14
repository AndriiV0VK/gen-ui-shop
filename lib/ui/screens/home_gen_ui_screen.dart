import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/role_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/chat_gen_ui_provider.dart';
import '../widgets/gen_ui_catalog/gen_ui_renderer.dart';

class HomeGenUiScreen extends ConsumerStatefulWidget {
  const HomeGenUiScreen({super.key});

  @override
  ConsumerState<HomeGenUiScreen> createState() => _HomeGenUiScreenState();
}

class _HomeGenUiScreenState extends ConsumerState<HomeGenUiScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitPrompt(String prompt) {
    if (prompt.trim().isEmpty) return;
    ref.read(chatGenUiProvider.notifier).sendPrompt(prompt.trim());
    _promptController.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(roleProvider);
    final cartItems = ref.watch(cartProvider);
    final chatState = ref.watch(chatGenUiProvider);

    final totalCartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 1,
        title: Text(
          isAdmin ? 'Панель Адміністратора' : 'Магазин техніки',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Row(
            children: [
              Text(
                isAdmin ? 'Адмін' : 'Клієнт',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? Colors.deepPurple : Colors.black87,
                ),
              ),
              Switch(
                value: isAdmin,
                activeThumbColor: Colors.deepPurple,
                onChanged: (val) {
                  ref.read(roleProvider.notifier).toggle(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val
                          ? 'Увімкнено режим: Адміністратор'
                          : 'Увімкнено режим: Звичайний користувач'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          IconButton(
            icon: Badge(
              isLabelVisible: totalCartCount > 0,
              label: Text('$totalCartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            tooltip: 'Оформити замовлення',
            onPressed: () {
              ref.read(chatGenUiProvider.notifier).openCheckoutForm();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (chatState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Text(
                chatState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return GenUiRenderer(response: message);
              },
            ),
          ),

          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Штучний інтелект генерує інтерфейс...',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

          // Швидкі підказки для демонстрації
          //_buildQuickSuggestions(isAdmin),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: isAdmin
                            ? 'Запитайте про залишки, графіки чи замовлення...'
                            : 'Пошукайте техніку, порівняйте товари...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _submitPrompt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: isAdmin ? Colors.deepPurple : Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () => _submitPrompt(_promptController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Швидкі сценарії
  /* Widget _buildQuickSuggestions(bool isAdmin) {
    final List<String> suggestions = isAdmin
        ? [
            'Покажи не опрацьовані замовлення',
            'Діаграма залишків на складі по категоріям',
            'Статистика куплених товарів',
          ]
        : [
            'Покажи смартфони до 30000 від Samsung',
            'Порівняй телевізори в магазині',
            'Хочу перейти до оформлення замовлення',
          ];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(suggestions[i], style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            onPressed: () => _submitPrompt(suggestions[i]),
          );
        },
      ),
    );
  } */
}