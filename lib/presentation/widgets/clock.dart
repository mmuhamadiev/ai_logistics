import 'package:flutter/material.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class BeautifulClock extends StatefulWidget {
  const BeautifulClock({Key? key}) : super(key: key);

  @override
  State<BeautifulClock> createState() => _BeautifulClockState();
}

class _BeautifulClockState extends State<BeautifulClock> {
  late String _formattedLocalTime;
  late String _formattedGermanTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateTimes();
      });
    });
  }

  void _updateTimes() {
    _formattedLocalTime = _getFormattedLocalTime();
    _formattedGermanTime = _getFormattedGermanTime();
  }

  String _getFormattedLocalTime() {
    final now = DateTime.now();
    // Use shorter format for a compact display (e.g., "HH:mm:ss")
    return DateFormat('HH:mm:ss').format(now);
  }

  String _getFormattedGermanTime() {
    final germanTimeZone = tz.getLocation('Europe/Berlin');
    final nowGerman = tz.TZDateTime.now(germanTimeZone);
    return DateFormat('HH:mm:ss').format(nowGerman);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Local Time Section
        Row(
          children: [
            Icon(Icons.access_time, color: AppColors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              'Local:',
              style: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(
              _formattedLocalTime,
              style: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.lightBlue),
            ),
          ],
        ),
        // Vertical Divider
        Container(
          width: 1,
          height: 24,
          color: Colors.grey,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        // German Time Section
        Row(
          children: [
            Icon(Icons.access_time, color: AppColors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              'Germany:',
              style: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(
              _formattedGermanTime,
              style: AppTextStyles.body14RobotoMedium.copyWith(color: AppColors.lightBlue),
            ),
          ],
        ),
      ],
    );
  }
}
