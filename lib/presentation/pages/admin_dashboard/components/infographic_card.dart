// Infographic Card Builder
import 'package:flutter/material.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';

Widget buildInfographicCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Expanded(
    child: Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.head25RobotoRegular.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.head24RobotoMedium.copyWith(color: color)
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}