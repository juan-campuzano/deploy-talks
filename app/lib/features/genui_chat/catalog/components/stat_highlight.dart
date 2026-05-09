import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final statHighlightItem = CatalogItem(
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
    required: [],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final label = (data['label'] as String?) ?? '';
    final value = (data['value'] as String?) ?? '';
    final unit = data['unit'] as String?;
    final contextText = data['context'] as String?;

    return cardWrapper(
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
