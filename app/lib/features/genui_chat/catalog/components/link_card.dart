import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final linkCardItem = CatalogItem(
  name: 'LinkCard',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Resource title'),
      'description': Schema.string(
        description: 'Brief description of the resource',
      ),
      'url': Schema.string(description: 'Full URL of the resource'),
    },
    required: [],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = (data['title'] as String?) ?? '';
    final description = data['description'] as String?;
    final url = (data['url'] as String?) ?? '';

    return cardWrapper(
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
