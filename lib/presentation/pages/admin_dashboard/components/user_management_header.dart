import 'package:flutter/material.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';

class UserManagementSearchBar extends StatelessWidget {
  final VoidCallback onAddUser;
  final Function(String query) onSearch;
  final TextEditingController searchController;

  const UserManagementSearchBar({
    required this.onAddUser,
    required this.onSearch,
    required this.searchController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Search Bar, Filters, and Add User
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: "Search",
              labelStyle: AppTextStyles.head20RobotoRegular,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Add User Button
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onAddUser,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add user",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

