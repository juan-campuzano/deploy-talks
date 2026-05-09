import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';
import 'card_wrapper.dart';

final comparisonTableItem = CatalogItem(
  name: 'ComparisonTable',
  dataSchema: ObjectSchema(
    properties: {
      'title': Schema.string(description: 'Optional table title'),
      'headers': ListSchema(
        description:
            'Column headers, e.g. ["Feature", "Flutter", "React Native"]',
      ),
      'rows': ListSchema(
        description:
            'Each row as cells separated by " | ", e.g. "Performance | Excellent | Good"',
      ),
    },
    required: [],
  ),
  widgetBuilder: (ctx) {
    final data = ctx.data as Map<String, Object?>;
    final title = data['title'] as String?;
    final rawHeaders = data['headers'];
    final rawRows = data['rows'];

    List<String> headers = [];
    if (rawHeaders is List) {
      headers = rawHeaders.map((e) => e.toString()).toList();
    }

    List<List<String>> rows = [];
    if (rawRows is List) {
      rows = rawRows.map((e) => e.toString().split(' | ')).toList();
    }

    return cardWrapper(
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
