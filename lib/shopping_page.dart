// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_modal.dart';

class ShoppingPage extends StatefulWidget {
  final String jsonData;

  const ShoppingPage({super.key, required this.jsonData});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<dynamic> items = [];
  Map<String, int> selectedItems = {};
  List<Map<String, dynamic>> placedOrders = [];

  @override
  void initState() {
    super.initState();
    items = json.decode(widget.jsonData);
    _getPlacedOrdersFromStorage();
  }

  void _clearCart() {
    setState(() {
      // Clear the selected items in the cart
      selectedItems.clear();
    });
  }

  Future<void> _exportOrdersToCSV(
      List<Map<String, dynamic>> orders, BuildContext context) async {
    // Prompt the user to input the file name
    final fileName = await _getFileNameFromUser(context);

    if (fileName != null) {
      // Open file picker to select a location to save the file
      String? result = await FilePicker.platform.getDirectoryPath();

      if (result != null) {
        // Get the file path
        String filePath = result;

        // Write CSV content
        List<List<dynamic>> rows = [];

        // Add CSV header
        rows.add(['Order Name', 'Product', 'Quantity', 'Price', 'Total Price']);

        // Iterate through orders
        for (var order in orders) {
          String orderName = order['name'] ?? 'Unknown';
          double totalPrice = 0.0;

          // Calculate total price for the order
          order.forEach((product, quantity) {
            if (product != 'name') {
              double price = getPriceForItem(product);
              rows.add([orderName, product, quantity, price, '']);
              totalPrice += price * quantity;
            }
          });

          // Add a row for the total price of the order
          rows.add([orderName, '', '', '', totalPrice]);
        }

        String csv = const ListToCsvConverter().convert(rows);

        try {
          // Write content to file
          File file = File('$filePath/$fileName.csv');
          await file.writeAsString(csv);

          // Show a message using SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Orders exported to $filePath/$fileName.csv'),
              duration:
                  const Duration(seconds: 3), // Adjust the duration as needed
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error exporting orders. Please try again.'),
              duration: Duration(seconds: 3), // Adjust the duration as needed
            ),
          );
        }
      } else {
        // User canceled the file picker or an error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export canceled or an error occurred.'),
            duration: Duration(seconds: 3), // Adjust the duration as needed
          ),
        );
      }
    }
  }

  Future<String?> _getFileNameFromUser(BuildContext context) {
    TextEditingController fileNameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: 'Enter file name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(fileNameController.text);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void updateCart(String name, bool increment) {
    setState(() {
      if (selectedItems.containsKey(name)) {
        if (increment) {
          selectedItems[name] = selectedItems[name]! + 1;
        } else {
          if (selectedItems[name] == 1) {
            selectedItems.remove(name);
          } else {
            selectedItems[name] = selectedItems[name]! - 1;
          }
        }
      } else {
        if (increment) {
          selectedItems[name] = 1;
        }
      }
    });
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var item in selectedItems.entries) {
      total += (item.value * getPriceForItem(item.key));
    }
    return total;
  }

  double getPriceForItem(String itemName) {
    for (var i = 0; i < items.length; i += 2) {
      if (items[i] == itemName) {
        return items[i + 1]['prijs'].toDouble();
      }
    }
    return 0.0;
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Adjust the height factor as needed
          child: Container(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CartModal(
                        selectedItems: selectedItems,
                        getPriceForItem: getPriceForItem,
                        updateCart: updateCart,
                        resetCartAndComponents: _resetCartAndComponents,
                        clearCart: _clearCart,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetCartAndComponents() {
    setState(() {
      placedOrders.add(Map<String, dynamic>.from(selectedItems));
      selectedItems.clear();
    });
    _savePlacedOrdersToStorage();
    Navigator.pop(context);
  }

  void _editOrderName(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        if (index >= 0 && index < placedOrders.length) {
          newName = placedOrders[index]['name'] ?? '';
        }

        TextEditingController textEditingController =
            TextEditingController(text: newName);

        return AlertDialog(
          title: const Text('Aanpasing naam bestelling'),
          content: TextField(
            controller: textEditingController,
            onChanged: (value) {
              setState(() {
                newName = value;
              });
            },
            decoration: const InputDecoration(hintText: 'Voer nieuwe naam in'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (index >= 0 && index < placedOrders.length) {
                  setState(() {
                    placedOrders[index]['name'] = newName;
                  });
                  _savePlacedOrdersToStorage();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showPlacedOrders() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bestellingen',
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
                          int value = entry.value is int
                              ? entry.value
                              : int.tryParse(entry.value.toString()) ?? 0;
                          return MapEntry(entry.key, value);
                        }).toList();

                        double totalPrice =
                            calculateTotalPriceForOrder(typedOrder);

                        return ExpansionTile(
                          title: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editOrderName(index);
                                },
                              ),
                              Text(order['name'] ??
                                  ''), // Display the order name
                              const Spacer(), // Add this spacer
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    placedOrders.removeAt(index);
                                  });
                                  _savePlacedOrdersToStorage();
                                },
                              ),
                            ],
                          ),
                          children: [
                            ...typedOrder.map((entry) => ListTile(
                                  title: Text('${entry.key} x ${entry.value}'),
                                  subtitle: Text(
                                      'Prijs: €${entry.value * getPriceForItem(entry.key)}'),
                                )),
                            ListTile(
                              title: Text('Totaal Prijs: €$totalPrice'),
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
                        _exportOrdersToCSV(placedOrders, context);
                      },
                      child: const Text('Export Orders to CSV'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Future<void> _savePlacedOrdersToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedOrders = placedOrders.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> order = entry.value;
      if (order.containsKey('name')) {
        return json.encode(order);
      } else {
        String orderName = 'bestelling${index + 1}';
        order['name'] = orderName;
        return json.encode(order);
      }
    }).toList();
    await prefs.setStringList('placed_orders', encodedOrders);
  }

  void _getPlacedOrdersFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedOrders = prefs.getStringList('placed_orders');
    if (encodedOrders != null) {
      setState(() {
        placedOrders = encodedOrders.map((encodedOrder) {
          Map<String, dynamic> decodedOrder = json.decode(encodedOrder);
          return decodedOrder;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 256,
            ),
            itemCount: items.length ~/ 2,
            itemBuilder: (context, index) {
              dynamic item = items[index * 2];

              dynamic priceData = items[index * 2 + 1];

              int itemCount = selectedItems[item] ?? 0;

              return GestureDetector(
                onTap: () {
                  updateCart(item, true);
                },
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              item.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (priceData['asset_image'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Image.asset(
                                    priceData['asset_image'],
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                              Text(
                                'Prijs: € ${priceData['prijs'].toString()}',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              updateCart(item, false);
                            },
                          ),
                          Text(itemCount.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              updateCart(item, true);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xFFB71C1C),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prijs: €${calculateTotalPrice().toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              ElevatedButton(
                onPressed: _showPlacedOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: const Size.fromHeight(55),
                ),
                child: const Text(
                  'Bestellingen',
                  style: TextStyle(color: Color(0xFFFFA000), fontSize: 16.0),
                ),
              ),
              FloatingActionButton(
                onPressed: _showCart,
                backgroundColor: const Color(0xFFFFA000),
                foregroundColor: Colors.white,
                child: const Icon(Icons.shopping_cart),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
