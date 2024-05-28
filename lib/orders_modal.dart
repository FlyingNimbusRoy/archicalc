import 'package:flutter/material.dart';
import 'dart:convert';

class OrdersModal extends StatelessWidget {
  final List<Map<String, dynamic>> placedOrders;
  final Function(int) editOrderName;
  final Function(int) removeOrder;
  final Function(List<Map<String, dynamic>>) savePlacedOrdersToStorage;
  final Function(List<Map<String, dynamic>>, Function) exportOrdersToCSV;

  const OrdersModal({
    Key? key,
    required this.placedOrders,
    required this.editOrderName,
    required this.removeOrder,
    required this.savePlacedOrdersToStorage,
    required this.exportOrdersToCSV,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: placedOrders.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> order = placedOrders[index];

                // Exclude the 'name' field when populating the products
                List<MapEntry<String, int>> typedOrder = order.entries
                    .where((entry) => entry.key != 'name')
                    .map((entry) {
                  // Ensure that the value can be converted to an integer before casting
                  int value =
                  entry.value is int ? entry.value : int.tryParse(entry.value.toString()) ?? 0;
                  return MapEntry(entry.key, value);
                }).toList();

                double totalPrice = calculateTotalPriceForOrder(typedOrder);

                return ExpansionTile(
                  title: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          editOrderName(index);
                        },
                      ),
                      Text(order['name'] ?? ''), // Display the order name
                      const Spacer(), // Add this spacer
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          removeOrder(index);
                        },
                      ),
                    ],
                  ),
                  children: [
                    ...typedOrder.map((entry) => ListTile(
                      title: Text('${entry.key} x ${entry.value}'),
                      subtitle:
                      Text('Price: ${entry.value * getPriceForItem(entry.key)}'),
                    )),
                    ListTile(
                      title: Text('Total Price: ${totalPrice.toStringAsFixed(2)}'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                exportOrdersToCSV(placedOrders, getPriceForItem);
              },
              child: const Text('Export Orders to CSV'),
            ),
          ],
        ),
      ),
    );
  }

  double calculateTotalPriceForOrder(List<MapEntry<String, int>> order) {
    double totalPrice = 0.0;
    for (var entry in order) {
      String itemName = entry.key;
      int quantity = entry.value;
      double itemPrice = getPriceForItem(itemName);
      totalPrice += (itemPrice * quantity);
    }
    return totalPrice;
  }

  double getPriceForItem(String itemName) {
    for (var order in placedOrders) {
      if (order.containsKey(itemName)) {
        return order[itemName]['prijs'].toDouble();
      }
    }
    return 0.0;
  }
}
