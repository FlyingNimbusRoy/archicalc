// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CartModal extends StatefulWidget {
  final Map<String, int> selectedItems;
  final double Function(String) getPriceForItem;
  final Function(String, bool) updateCart;
  final VoidCallback resetCartAndComponents;
  final VoidCallback clearCart;

  const CartModal({
    super.key,
    required this.selectedItems,
    required this.getPriceForItem,
    required this.updateCart,
    required this.resetCartAndComponents,
    required this.clearCart,
  });

  @override
  _CartModalState createState() => _CartModalState();
}

class _CartModalState extends State<CartModal> {
  @override
  Widget build(BuildContext context) {
    // Calculate the total price from the items currently in the cart
    double totalPrice = 0.0;
    widget.selectedItems.forEach((itemName, quantity) {
      double itemPrice = widget.getPriceForItem(itemName);
      totalPrice += itemPrice * quantity;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(0),
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Price: €$totalPrice',
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: ListView.builder(
                  itemCount: widget.selectedItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    String itemName =
                        widget.selectedItems.keys.elementAt(index);

                    int quantity = widget.selectedItems[itemName]!;
                    double totalPrice =
                        widget.getPriceForItem(itemName) * quantity;

                    return ListTile(
                      title: Text('$itemName x $quantity'),
                      subtitle: Text('Prijs: €$totalPrice'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            widget.updateCart(
                                itemName, false); // Decrease quantity
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: const Color.fromRGBO(
                    245, 246, 250, 1.0), // Background color
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0), // Adjust padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.resetCartAndComponents,
                      child: const Text('Bevestig bestelling'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.clearCart(); // Call the clearCart function
                        Navigator.pop(context); // Pop the context
                      },
                      child: const Text('Clear Cart'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
