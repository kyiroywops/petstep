import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de la sesión de fotos
class PhotoSessionState {
  final int currentStep;      // Paso actual (1..4) para fotos obligatorias
  final List<File> mandatory; // Fotos obligatorias
  final List<File> extras;    // Fotos adicionales

  const PhotoSessionState({
    required this.currentStep,
    required this.mandatory,
    required this.extras,
  });

  PhotoSessionState copyWith({
    int? currentStep,
    List<File>? mandatory,
    List<File>? extras,
  }) {
    return PhotoSessionState(
      currentStep: currentStep ?? this.currentStep,
      mandatory:   mandatory   ?? this.mandatory,
      extras:      extras      ?? this.extras,
    );
  }
}

/// Notifier que maneja la sesión de fotos
class PhotoSessionNotifier extends StateNotifier<PhotoSessionState> {
  PhotoSessionNotifier()
      : super(
          PhotoSessionState(
            currentStep: 1,
            mandatory: [],
            extras: [],
          ),
        );

  /// Agrega foto obligatoria
  void addMandatory(File photo) {
    final updatedMandatory = [...state.mandatory, photo];
    final newStep = state.currentStep + 1;
    state = state.copyWith(
      currentStep: newStep,
      mandatory: updatedMandatory,
    );
  }

  /// Agrega foto adicional
  void addExtra(File photo) {
    final updatedExtras = [...state.extras, photo];
    state = state.copyWith(extras: updatedExtras);
  }

  void reset() {
    state = PhotoSessionState(
      currentStep: 1,
      mandatory: [],
      extras: [],
    );
  }
}

/// Provider global
final photoSessionProvider =
    StateNotifierProvider<PhotoSessionNotifier, PhotoSessionState>((ref) {
  return PhotoSessionNotifier();
});
