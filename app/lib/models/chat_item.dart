/// Represents an item in the chat list — either a rendered message bubble
/// or a subtle system event (join / leave notification).
sealed class ChatItem {
  const ChatItem();
}

class MessageItem extends ChatItem {
  const MessageItem(this.surfaceId);
  final String surfaceId;
}

class SystemEventItem extends ChatItem {
  const SystemEventItem(this.text);
  final String text;
}
