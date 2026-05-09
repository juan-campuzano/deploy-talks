import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final textCardItem = CatalogItem(
  name: 'TextCard',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Short heading for the card'),
      'body': Schema.string(description: 'Main prose content'),
      'emoji': Schema.string(description: 'Optional decorative emoji'),
    },
    required: [],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = (data['title'] as String?) ?? '';
    final body = (data['body'] as String?) ?? '';
    final emoji = data['emoji'] as String?;

    return cardWrapper(
      leftBorderColor: AppColors.primary,
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
    );
  },
);
