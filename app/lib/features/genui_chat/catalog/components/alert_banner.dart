import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../../../../theme.dart';

final alertBannerItem = CatalogItem(
  name: 'AlertBanner',
  dataSchema: ObjectSchema(
    properties: {
      'type': Schema.string(
        description: 'One of: info, warning, error, success',
      ),
      'title': Schema.string(description: 'Short alert heading'),
      'message': Schema.string(description: 'Alert body text'),
    },
    required: [],
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
