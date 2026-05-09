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
- Use ItemList for simple enumerations or bullet/numbered lists.
- Use CodeBlock when the answer involves code, terminal commands, or syntax examples.
- Use StatHighlight for a single key fact, metric, number, or date.
- Use ComparisonTable when comparing two or more options, technologies, or approaches side by side.
- Use StepByStep for sequential instructions, tutorials, or how-to guides with numbered steps.
- Use ProConList for advantages vs disadvantages, strengths vs weaknesses, or pros vs cons.
- Use KeyValueGrid when presenting multiple related metrics or key facts together.
- Use AlertBanner for important notices, warnings, tips, or error messages.
- Use QuoteBlock for definitions, notable quotes, or key phrases worth highlighting.
- Use Timeline for chronological events, history, or sequences with associated dates.
- Use LinkCard when recommending an external resource with a URL.
Never respond with plain text — always use a GenUI surface.
''';

/// Builds the GenUI chatbot catalog with 12 component types.
Catalog buildGenuiChatbotCatalog() {
  return Catalog(
    [
      _textCardItem,
      _itemListItem,
      _codeBlockItem,
      _statHighlightItem,
      _comparisonTableItem,
      _stepByStepItem,
      _proConListItem,
      _keyValueGridItem,
      _alertBannerItem,
      _quoteBlockItem,
      _timelineItem,
      _linkCardItem,
    ],
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

// ── ComparisonTable ───────────────────────────────────────────────────────────

final _comparisonTableItem = CatalogItem(
  name: 'ComparisonTable',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional table title'),
      'headers': ListSchema(
        items: Schema.string(),
        description:
            'Column headers, e.g. ["Feature", "Flutter", "React Native"]',
      ),
      'rows': ListSchema(
        items: Schema.string(),
        description:
            'Each row as cells separated by " | ", e.g. "Performance | Excellent | Good"',
      ),
    },
    required: ['headers', 'rows'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawHeaders = data['headers'];
    final rawRows = data['rows'];

    List<String> headers = [];
    if (rawHeaders is List)
      headers = rawHeaders.map((e) => e.toString()).toList();

    List<List<String>> rows = [];
    if (rawRows is List) {
      rows = rawRows.map((e) => e.toString().split(' | ')).toList();
    }

    return _cardWrapper(
      leftBorderColor: AppColors.primary,
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
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              for (int i = 0; i < headers.length; i++)
                i: const FlexColumnWidth(),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.surfaceEl),
                children: headers
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBright,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...rows.map(
                (cells) => TableRow(
                  children: List.generate(headers.length, (i) {
                    final cell = i < cells.length ? cells[i].trim() : '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        cell,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

// ── StepByStep ────────────────────────────────────────────────────────────────

final _stepByStepItem = CatalogItem(
  name: 'StepByStep',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading for the steps'),
      'steps': ListSchema(
        items: Schema.string(),
        description:
            'Ordered steps; each step is a complete instruction sentence',
      ),
    },
    required: ['steps'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawSteps = data['steps'];

    List<String> steps = [];
    if (rawSteps is List) steps = rawSteps.map((e) => e.toString()).toList();

    return _cardWrapper(
      leftBorderColor: AppColors.primaryBright,
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
            const SizedBox(height: 12),
          ],
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDim,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBright,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step,
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

// ── ProConList ────────────────────────────────────────────────────────────────

final _proConListItem = CatalogItem(
  name: 'ProConList',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'pros': ListSchema(
        items: Schema.string(),
        description: 'Advantages or positive points',
      ),
      'cons': ListSchema(
        items: Schema.string(),
        description: 'Disadvantages or negative points',
      ),
    },
    required: ['pros', 'cons'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawPros = data['pros'];
    final rawCons = data['cons'];

    List<String> pros = [];
    if (rawPros is List) pros = rawPros.map((e) => e.toString()).toList();
    List<String> cons = [];
    if (rawCons is List) cons = rawCons.map((e) => e.toString()).toList();

    Widget buildColumn(
      String header,
      List<String> items,
      Color headerColor,
      Color bulletColor,
    ) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: headerColor,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: bulletColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
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
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumn('✅ Pros', pros, AppColors.accent, AppColors.accent),
              const SizedBox(width: 8),
              Container(width: 1, color: AppColors.border),
              const SizedBox(width: 8),
              buildColumn('❌ Cons', cons, AppColors.danger, AppColors.danger),
            ],
          ),
        ],
      ),
    );
  },
);

// ── KeyValueGrid ──────────────────────────────────────────────────────────────

final _keyValueGridItem = CatalogItem(
  name: 'KeyValueGrid',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'labels': ListSchema(
        items: Schema.string(),
        description: 'Short label for each metric',
      ),
      'values': ListSchema(
        items: Schema.string(),
        description: 'Value for each metric',
      ),
    },
    required: ['labels', 'values'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawLabels = data['labels'];
    final rawValues = data['values'];

    List<String> labels = [];
    if (rawLabels is List) labels = rawLabels.map((e) => e.toString()).toList();
    List<String> values = [];
    if (rawValues is List) values = rawValues.map((e) => e.toString()).toList();

    final count = labels.length < values.length ? labels.length : values.length;

    return _cardWrapper(
      leftBorderColor: AppColors.primaryBright,
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
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(count, (i) {
              return Container(
                constraints: const BoxConstraints(minWidth: 100),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEl,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[i],
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      values[i],
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBright,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  },
);

// ── AlertBanner ───────────────────────────────────────────────────────────────

final _alertBannerItem = CatalogItem(
  name: 'AlertBanner',
  dataSchema: ObjectSchema(
    properties: {
      'type': Schema.string(
        description: 'One of: info, warning, error, success',
      ),
      'title': Schema.string(description: 'Short alert heading'),
      'message': Schema.string(description: 'Alert body text'),
    },
    required: ['type', 'title', 'message'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final type = (data['type'] as String?) ?? 'info';
    final title = (data['title'] as String?) ?? '';
    final message = (data['message'] as String?) ?? '';

    late Color borderColor;
    late Color bgColor;
    late String icon;

    switch (type) {
      case 'warning':
        borderColor = AppColors.warning;
        bgColor = const Color(0xFF1C1600);
        icon = '⚠️';
      case 'error':
        borderColor = AppColors.danger;
        bgColor = AppColors.dangerDim;
        icon = '🚨';
      case 'success':
        borderColor = AppColors.accent;
        bgColor = AppColors.accentDim;
        icon = '✅';
      default:
        borderColor = AppColors.primaryBright;
        bgColor = AppColors.primaryDim;
        icon = 'ℹ️';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: borderColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);

// ── QuoteBlock ────────────────────────────────────────────────────────────────

final _quoteBlockItem = CatalogItem(
  name: 'QuoteBlock',
  dataSchema: ObjectSchema(
    properties: {
      'quote': Schema.string(
        description: 'The quote, definition, or highlighted phrase',
      ),
      'attribution': Schema.string(description: 'Optional source or author'),
    },
    required: ['quote'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final quote = (data['quote'] as String?) ?? '';
    final attribution = data['attribution'] as String?;

    return _cardWrapper(
      leftBorderColor: AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          if (attribution != null && attribution.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '— $attribution',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  },
);

// ── Timeline ──────────────────────────────────────────────────────────────────

final _timelineItem = CatalogItem(
  name: 'Timeline',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'events': ListSchema(
        items: Schema.string(),
        description:
            'Each event as "date: description", e.g. "2024: Flutter 3.0 released"',
      ),
    },
    required: ['events'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawEvents = data['events'];

    List<String> events = [];
    if (rawEvents is List) events = rawEvents.map((e) => e.toString()).toList();

    final parsed = events.map((e) {
      final idx = e.indexOf(': ');
      if (idx == -1) return ('', e);
      return (e.substring(0, idx), e.substring(idx + 2));
    }).toList();

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
            const SizedBox(height: 12),
          ],
          ...parsed.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value.$1;
            final desc = entry.value.$2;
            final isLast = index == parsed.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(width: 2, height: 36, color: AppColors.border),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (date.isNotEmpty)
                          Text(
                            date,
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  },
);

// ── LinkCard ──────────────────────────────────────────────────────────────────

final _linkCardItem = CatalogItem(
  name: 'LinkCard',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Resource title'),
      'description': Schema.string(
        description: 'Brief description of the resource',
      ),
      'url': Schema.string(description: 'Full URL of the resource'),
    },
    required: ['title', 'url'],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = (data['title'] as String?) ?? '';
    final description = data['description'] as String?;
    final url = (data['url'] as String?) ?? '';

    return _cardWrapper(
      leftBorderColor: AppColors.primaryBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔗', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
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
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            url,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: AppColors.primaryBright,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryBright,
            ),
          ),
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
