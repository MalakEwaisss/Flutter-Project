// lib/models/chat_message.dart
class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final DateTime sentAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.sentAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      groupId: json['group_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      message: json['message'],
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  // Helper to check if message was sent today
  bool get isToday {
    final now = DateTime.now();
    return sentAt.year == now.year &&
        sentAt.month == now.month &&
        sentAt.day == now.day;
  }

  // Helper to format time
  String get formattedTime {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper to format date
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[sentAt.month - 1]} ${sentAt.day}, ${sentAt.year}';
  }
}