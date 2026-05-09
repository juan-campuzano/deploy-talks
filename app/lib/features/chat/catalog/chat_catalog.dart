import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// The name of the custom ChatBubble catalog item.
const String kChatBubbleType = 'ChatBubble';

/// Instructions appended to the system prompt for bubble rendering.
const String kChatBubbleSystemPromptFragment = '''
You render every chat message as a ChatBubble surface.
- When isOwn is true: align the bubble to the RIGHT and use a blue background.
- When isOwn is false: align the bubble to the LEFT and use a grey background.
- Always show the senderName above the bubble text, regardless of the isOwn value.
Always respond with a single createSurface call using the ChatBubble component as root.
''';

/// Returns a [Catalog] containing the [ChatBubble] CatalogItem.
Catalog buildChatCatalog() {
  final chatBubbleItem = CatalogItem(
    name: kChatBubbleType,
    dataSchema: ObjectSchema(
      properties: {
        'content': Schema.string(description: 'The message text'),
        'senderName': Schema.string(description: 'Display name of the sender'),
        'isOwn': Schema.boolean(
          description: 'True if the message belongs to the current user',
        ),
      },
      required: ['content', 'senderName', 'isOwn'],
    ),
    widgetBuilder: (CatalogItemContext ctx) {
      final data = ctx.data as Map<String, Object?>;
      final content = (data['content'] as String?) ?? '';
      final senderName = (data['senderName'] as String?) ?? '';
      final isOwn = (data['isOwn'] as bool?) ?? false;

      final alignment = isOwn
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start;
      final bubbleColor = isOwn
          ? const Color(0xFF2196F3)
          : const Color(0xFFE0E0E0);
      final textColor = isOwn ? Colors.white : Colors.black87;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: isOwn ? 0 : 4,
                right: isOwn ? 4 : 0,
                bottom: 2,
              ),
              child: Text(
                senderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF757575),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isOwn ? 16 : 4),
                  bottomRight: Radius.circular(isOwn ? 4 : 16),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    },
  );

  return Catalog(
    [chatBubbleItem],
    catalogId: 'com.deploytalks.chat_catalog',
    systemPromptFragments: [kChatBubbleSystemPromptFragment],
  );
}
