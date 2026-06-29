class ConversationMessage {
  final String id;
  final String text;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final bool isError;
  final String? errorMessage;

  const ConversationMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.timestamp,
    this.isError = false,
    this.errorMessage,
  });

  ConversationMessage copyWith({
    String? id,
    String? text,
    String? role,
    DateTime? timestamp,
    bool? isError,
    String? errorMessage,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
