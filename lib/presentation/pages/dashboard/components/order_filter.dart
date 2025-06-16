import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hegelmann_order_automation/config/app_colors.dart';
import 'package:hegelmann_order_automation/config/app_text_styles.dart';
import 'package:hegelmann_order_automation/config/constants.dart';
import 'package:hegelmann_order_automation/domain/models/order_model.dart';
import 'package:hegelmann_order_automation/presentation/widgets/notifications/error_notification.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
  final String? fromCountry;
  final String? toCountry;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterDialog({
    Key? key,
    this.fromCountry,
    this.toCountry,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? fromCountry;
  String? toCountry;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fromCountry = widget.fromCountry;
    toCountry = widget.toCountry;
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    DateTime firstDate = DateTime(2024);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null; // Reset end date if it's before start date
          }
        } else {
          if (startDate != null && picked.isBefore(startDate!)) {
            showErrorNotification(context, "End date cannot be before start date.");
          } else {
            endDate = picked;
          }
        }
      });
    }
  }

  void _applyPreset(int days) {
    setState(() {
      endDate = DateTime.now();
      startDate = endDate!.subtract(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Filter Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Country Selection
            Text("Country Selection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                // From Country Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fromCountry,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: "From Country"),
                    items: countries.map((String country) {
                      return DropdownMenuItem<String>(value: country, child: Text(country));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        fromCountry = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                // To Country Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: toCountry,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: "To Country"),
                    items: countries.map((String country) {
                      return DropdownMenuItem<String>(value: country, child: Text(country));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        toCountry = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Date Range
            Text("Pickup Date Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                // Start Date Picker
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, true);
                    },
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      hintText: "yyyy-MM-dd",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : '',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // End Date Picker
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, false);
                    },
                    decoration: InputDecoration(
                      labelText: "End Date",
                      hintText: "yyyy-MM-dd",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : '',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Preset Date Filters
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    _applyPreset(7);
                  },
                  child: Text("Last 7 days", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    _applyPreset(30);
                  },
                  child: Text("Last 30 days", style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),

            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 16),

            // Buttons (Clear, Cancel, Apply)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        context.pop();
                      },
                      label: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        context.pop({
                          'From': fromCountry,
                          'To': toCountry,
                          'StartDate': startDate,
                          'EndDate': endDate,
                        });
                      },
                      child: Text("Apply Filter", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
