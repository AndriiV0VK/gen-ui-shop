import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleNotifier extends Notifier<bool> {
  @override
  bool build() => false; 
  void toggle(bool value) => state = value;
}

final roleProvider = NotifierProvider<RoleNotifier, bool>(RoleNotifier.new);