part of 'buddy_bloc.dart';

class BuddyState extends Equatable {
  final Map<int, String> prompt;
  final String response;
  final String input;
  final BuddyStatus status;
  final int currentId;
  final bool isMicAvailable;
  final bool isListening;
  final String feedback;
  final BuddyMode mode;
  final bool canScrollTop;
  final double deviceHeight;

  const BuddyState({
    required this.prompt,
    required this.response,
    required this.input,
    required this.status,
    required this.currentId,
    required this.isMicAvailable,
    required this.isListening,
    required this.feedback,
    required this.mode,
    required this.canScrollTop,
    required this.deviceHeight,
  });

  @override
  List<Object> get props => [
        prompt,
        response,
        input,
        status,
        currentId,
        isMicAvailable,
        isListening,
        feedback,
        mode,
        canScrollTop,
        deviceHeight
      ];

  BuddyState copyWith({
    Map<int, String>? prompt,
    String? response,
    String? input,
    BuddyStatus? status,
    int? currentId,
    bool? isMicAvailable,
    bool? isListening,
    String? feedback,
    BuddyMode? mode,
    bool? canScrollTop,
    double? deviceHeight,
  }) {
    return BuddyState(
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      input: input ?? this.input,
      status: status ?? this.status,
      currentId: currentId ?? this.currentId,
      isMicAvailable: isMicAvailable ?? this.isMicAvailable,
      isListening: isListening ?? this.isListening,
      feedback: feedback ?? this.feedback,
      mode: mode ?? this.mode,
      canScrollTop: canScrollTop ?? this.canScrollTop,
      deviceHeight: deviceHeight ?? this.deviceHeight,
    );
  }
}

enum BuddyStatus {
  idle,
  busy,
  error,
}

enum BuddyMode {
  idle,
  listening,
  speak,
}
