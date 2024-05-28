import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

Future<void> exportOrdersToCSV(
    List<Map<String, dynamic>> orders,
    double Function(String) getPriceForItem,
    ) async {
  List<List<dynamic>> rows = [];
  for (var order in orders) {
    String orderName = order['name'] ?? 'Bestelling';
    List<dynamic> row = [orderName];
    for (var entry in order.entries) {
      if (entry.key != 'name') {
        String itemName = entry.key;
        int quantity = entry.value;
        double price = getPriceForItem(itemName);
        row.addAll([itemName, quantity, price, quantity * price]);
      }
    }
    rows.add(row);
  }

  String csv = const ListToCsvConverter().convert(rows);
  Directory directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/orders.csv');
  await file.writeAsString(csv);
}
