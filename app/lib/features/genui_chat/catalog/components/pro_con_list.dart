import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final proConListItem = CatalogItem(
  name: 'ProConList',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'pros': ListSchema(description: 'Advantages or positive points'),
      'cons': ListSchema(description: 'Disadvantages or negative points'),
    },
    required: [],
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

    return cardWrapper(
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
