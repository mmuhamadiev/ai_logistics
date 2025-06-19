import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/domain/models/order_group_model.dart';

class GroupOrderFilter extends StatefulWidget {
  final List<OrderGroupModel> groups;
  final Function(Map<String, dynamic>) onApplyFilter;

  const GroupOrderFilter({
    Key? key,
    required this.groups,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  _GroupOrderFilterState createState() => _GroupOrderFilterState();
}

class _GroupOrderFilterState extends State<GroupOrderFilter> {
  Map<String, dynamic> selectedFilters = {};

  void _openFilterDialog() async {
    final filters = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => GroupFilterDialog(groups: widget.groups, currentFilters: selectedFilters),
    );

    if (filters != null) {
      setState(() {
        selectedFilters = filters;
      });
      widget.onApplyFilter(selectedFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (selectedFilters.isNotEmpty)...[
          SizedBox(
            width: 400,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.0,
                children: selectedFilters.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    onDeleted: () {
                      setState(() {
                        selectedFilters.remove(entry.key);
                      });
                      widget.onApplyFilter(selectedFilters);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        ElevatedButton.icon(
          icon: const Icon(Icons.filter_list),
          label: const Text('Filter'),
          onPressed: _openFilterDialog,
        ),
      ],
    );
  }
}

class GroupFilterDialog extends StatefulWidget {
  final List<OrderGroupModel> groups;
  final Map<String, dynamic> currentFilters;

  const GroupFilterDialog({
    Key? key,
    required this.groups,
    required this.currentFilters,
  }) : super(key: key);

  @override
  _GroupFilterDialogState createState() => _GroupFilterDialogState();
}

class _GroupFilterDialogState extends State<GroupFilterDialog> {
  String? selectedFrom;
  String? selectedTo;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedFrom = widget.currentFilters['From'];
    selectedTo = widget.currentFilters['To'];
    selectedDateRange = widget.currentFilters['DateRange'];
  }

  void _applyFilters() {
    Navigator.pop(context, {
      if (selectedFrom != null) 'From': selectedFrom,
      if (selectedTo != null) 'To': selectedTo,
      if (selectedDateRange != null) 'DateRange': selectedDateRange,
    });
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = widget.groups.expand((group) => group.orders).toList();

    final fromCountryCodes =
    allOrders.map((order) => order.pickupPlace.countryCode).toSet().toList();
    final toCountryCodes =
    allOrders.map((order) => order.deliveryPlace.countryCode).toSet().toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Group Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPostcodeDropdown(
              label: 'From Country',
              items: fromCountryCodes,
              selectedValue: selectedFrom,
              onChanged: (value) => setState(() => selectedFrom = value),
            ),
            const SizedBox(height: 8),
            _buildPostcodeDropdown(
              label: 'To Country',
              items: toCountryCodes,
              selectedValue: selectedTo,
              onChanged: (value) => setState(() => selectedTo = value),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date Range'),
              subtitle: Text(selectedDateRange == null
                  ? 'No range selected'
                  : '${selectedDateRange!.start.toLocal()} - ${selectedDateRange!.end.toLocal()}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: selectedDateRange,
                );
                if (range != null) {
                  setState(() {
                    selectedDateRange = range;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostcodeDropdown({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((code) {
          return DropdownMenuItem(
            value: code,
            child: Text(code),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8)
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
