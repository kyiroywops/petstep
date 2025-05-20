import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fishbyte/infrastructure/models/photo_session_state.dart';

//////////////////////////////////////////////////////////////
// NOTIFIER: maneja addMandatory, addExtra, switchToExtraMode, reset
//////////////////////////////////////////////////////////////
class PhotoSessionNotifier extends StateNotifier<PhotoSessionState> {
  PhotoSessionNotifier()
      : super(PhotoSessionState(currentStep: 1, mandatory: [], extras: []));

  void addMandatory(File photo) {
    final updated = [...state.mandatory, photo];
    state = state.copyWith(
      mandatory: updated,
      currentStep: state.currentStep + 1,
    );
  }

  void replaceMandatory(int index, File newFile) {
    final updated = [...state.mandatory];
    updated[index] = newFile;
    state = state.copyWith(mandatory: updated);
  }

  void replaceExtra(int index, File newFile) {
    final updated = [...state.extras];
    updated[index] = newFile;
    state = state.copyWith(extras: updated);
  }

  void addExtra(File photo) {
    final updated = [...state.extras, photo];
    state = state.copyWith(extras: updated);
  }

  /// Forzamos step >= 5 => modo foto adicional
  void switchToExtraMode() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: 5);
    }
  }

  void reset() {
    state = PhotoSessionState(currentStep: 1, mandatory: [], extras: []);
  }
}

//////////////////////////////////////////////////////////////
// PROVIDER
//////////////////////////////////////////////////////////////
final photoSessionProvider =
    StateNotifierProvider<PhotoSessionNotifier, PhotoSessionState>((ref) {
  return PhotoSessionNotifier();
});