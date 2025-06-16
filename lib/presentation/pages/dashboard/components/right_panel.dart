import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section: Newly Added Orders
        Expanded(
          flex: 1,
          child: _buildSection(
            title: "All Orders",
            itemCount: 5, // Replace with actual list length
            itemBuilder: (context, index) {
              return _buildOrderCard(orderId: "ORDERID${index + 1}");
            },
          ),
        ),
        const SizedBox(height: 16),
        // Section: Confirmed Connected Order Groups
        Expanded(
          flex: 1,
          child: _buildSection(
            title: "Confirmed Order Groups",
            itemCount: 3, // Replace with actual list length
            itemBuilder: (context, index) {
              return _buildConnectedGroupCard(groupId: "GROUPID${index + 1}");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {}, // Add navigation or interaction logic
                  child: const Text("View All"),
                ),
              ],
            ),
            const Divider(),
            // List of Items
            Expanded(
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({required String orderId}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: Colors.blue),
        title: Text("Order $orderId"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Pickup: Delhi"),
            Text("Delivery: Mumbai"),
          ],
        ),
        trailing: const Text("Details"),
      ),
    );
  }

  Widget _buildConnectedGroupCard({required String groupId}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.group, color: Colors.green),
        title: Text("Group $groupId"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("3 Orders Connected"),
            Text("Status: Confirmed"),
          ],
        ),
        trailing: const Text("Details"),
      ),
    );
  }
}
