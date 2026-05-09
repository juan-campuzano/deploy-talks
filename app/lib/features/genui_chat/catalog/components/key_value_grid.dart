import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final keyValueGridItem = CatalogItem(
  name: 'KeyValueGrid',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'labels': ListSchema(description: 'Short label for each metric'),
      'values': ListSchema(description: 'Value for each metric'),
    },
    required: [],
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

    return cardWrapper(
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
