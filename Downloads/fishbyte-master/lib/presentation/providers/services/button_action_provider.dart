// button_actions_provider.dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonActions {
  final VoidCallback? moveLeft;
  final VoidCallback? moveRight;
  final VoidCallback? next;

  ButtonActions({
    this.moveLeft,
    this.moveRight,
    this.next,
  }) {
    print('🔵 ButtonActions initialized');
  }

  void executeLeft() {
    print('⬅️ Left button pressed');
    moveLeft?.call();
  }

  void executeRight() {
    print('➡️ Right button pressed');
    moveRight?.call();
  }

  void executeNext() {
    print('✅ Next button pressed');
    next?.call();
  }
}

final buttonActionsProvider = StateProvider<ButtonActions>((ref) {
  print('🔄 ButtonActions provider created');
  return ButtonActions();
});