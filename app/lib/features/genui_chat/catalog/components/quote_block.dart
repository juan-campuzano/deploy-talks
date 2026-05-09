import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final quoteBlockItem = CatalogItem(
  name: 'QuoteBlock',
  dataSchema: ObjectSchema(
    properties: {
      'quote': Schema.string(
        description: 'The quote, definition, or highlighted phrase',
      ),
      'attribution': Schema.string(description: 'Optional source or author'),
    },
    required: [],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final quote = (data['quote'] as String?) ?? '';
    final attribution = data['attribution'] as String?;

    return cardWrapper(
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
