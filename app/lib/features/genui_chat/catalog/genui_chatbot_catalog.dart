import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../theme.dart';

/// The catalog ID used by this chatbot — Gemini must use exactly this value.
const String kGenuiChatbotCatalogId = 'com.deploytalks.genui_chatbot_catalog';

/// System prompt fragment instructing Gemini which catalog component to use.
const String kGenuiSystemPrompt = '''
You are a helpful assistant. Always respond using exactly one GenUI surface.
The catalog ID you MUST use in every createSurface message is: com.deploytalks.genui_chatbot_catalog
Do NOT use any other catalog ID or a generated UUID — always use exactly: com.deploytalks.genui_chatbot_catalog
Choose the component that best fits the content:
- Use TextCard for conceptual explanations, summaries, and prose answers.
- Use ItemList for any enumeration, ranking, step-by-step instructions, or multi-item answers.
- Use CodeBlock when the answer involves code, terminal commands, or syntax examples.
- Use StatHighlight for a single key fact, metric, number, or date.
Never respond with plain text — always use a GenUI surface.
''';

/// Builds the GenUI chatbot catalog with 4 component types.
Catalog buildGenuiChatbotCatalog() {
  return Catalog(
    [_textCardItem, _itemListItem, _codeBlockItem, _statHighlightItem],
    catalogId: 'com.deploytalks.genui_chatbot_catalog',
    systemPromptFragments: [kGenuiSystemPrompt],
  );
}

// ── TextCard ─────────────────────────────────────────────────────────────────

final _textCardItem = CatalogItem(
  name: 'TextCard',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Short heading for the card'),
      'body': Schema.string(description: 'Main prose content'),
      'emoji': Schema.string(description: 'Optional decorative emoji'),
    },
    required: ['title', 'body'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = (data['title'] as String?) ?? '';
    final body = (data['body'] as String?) ?? '';
    final emoji = data['emoji'] as String?;

    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (emoji != null && emoji.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(emoji, style: const TextStyle(fontSize: 18)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
      leftBorderColor: AppColors.primary,
    );
  },
);

// ── ItemList ─────────────────────────────────────────────────────────────────

final _itemListItem = CatalogItem(
  name: 'ItemList',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading for the list'),
      'items': ListSchema(
        items: Schema.string(),
        description: 'The list items',
      ),
      'ordered': Schema.boolean(
        description: 'True for numbered list, false for bullets',
      ),
    },
    required: ['items'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawItems = data['items'];
    final ordered = (data['ordered'] as bool?) ?? false;

    List<String> items = [];
    if (rawItems is List) {
      items = rawItems.map((e) => e.toString()).toList();
    }

    return _cardWrapper(
      leftBorderColor: AppColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final bullet = ordered ? '${index + 1}.' : '•';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  },
);

// ── CodeBlock ─────────────────────────────────────────────────────────────────

final _codeBlockItem = CatalogItem(
  name: 'CodeBlock',
  dataSchema: ObjectSchema(
    properties: {
      'language': Schema.string(
        description: "Language label, e.g. 'dart', 'bash'",
      ),
      'code': Schema.string(description: 'The code or command text'),
      'caption': Schema.string(
        description: 'Optional explanation below the block',
      ),
    },
    required: ['code'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final language = data['language'] as String?;
    final code = (data['code'] as String?) ?? '';
    final caption = data['caption'] as String?;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null && language.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      language,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBright,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (caption != null && caption.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    caption,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  },
);

// ── StatHighlight ─────────────────────────────────────────────────────────────

final _statHighlightItem = CatalogItem(
  name: 'StatHighlight',
  dataSchema: ObjectSchema(
    properties: {
      'label': Schema.string(description: 'Short description of the stat'),
      'value': Schema.string(description: 'The prominent number or fact'),
      'unit': Schema.string(description: "Optional unit, e.g. 'km', '%'"),
      'context': Schema.string(
        description: 'Optional one-line context sentence',
      ),
    },
    required: ['label', 'value'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final label = (data['label'] as String?) ?? '';
    final value = (data['value'] as String?) ?? '';
    final unit = data['unit'] as String?;
    final contextText = data['context'] as String?;

    return _cardWrapper(
      leftBorderColor: AppColors.primaryBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBright,
                  height: 1.1,
                ),
              ),
              if (unit != null && unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (contextText != null && contextText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              contextText,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  },
);

// ── Shared card wrapper ───────────────────────────────────────────────────────

Widget _cardWrapper({
  required Widget child,
  Color leftBorderColor = AppColors.border,
}) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 520),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: leftBorderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(14), child: child),
          ),
        ],
      ),
    ),
  );
}
