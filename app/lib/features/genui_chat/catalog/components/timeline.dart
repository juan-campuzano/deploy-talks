import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final timelineItem = CatalogItem(
  name: 'Timeline',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional heading'),
      'events': ListSchema(
        description:
            'Each event as "date: description", e.g. "2024: Flutter 3.0 released"',
      ),
    },
    required: [],
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
