import 'dart:io';

//////////////////////////////////////////////////////////////
// ESTADO: 4 fotos obligatorias + extras
//////////////////////////////////////////////////////////////
class PhotoSessionState {
  final int currentStep; // 1..4 => obligatorias, >=5 => fotos extra
  final List<File> mandatory;
  final List<File> extras;

  PhotoSessionState({
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
      mandatory: mandatory ?? this.mandatory,
      extras: extras ?? this.extras,
    );
  }
}