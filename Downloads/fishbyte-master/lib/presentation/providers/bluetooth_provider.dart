import 'package:fishbyte/presentation/providers/services/button_action_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/bluetooth_connection.dart';

final bluetoothProvider = ChangeNotifierProvider((ref) {
  final bluetooth = BluetoothConnection();
  
  // Observa los cambios en buttonActionsProvider
  ref.listen<ButtonActions>(buttonActionsProvider, (previous, next) {
    bluetooth.onMoveLeftPressed = next.moveLeft;
    bluetooth.onMoveRightPressed = next.moveRight;
    bluetooth.onNextPressed = next.next;
  });

  return bluetooth;
});