import 'package:flutter/material.dart';

class CartModal extends StatefulWidget {
  final Map<String, int> selectedItems;
  final double Function(String) getPriceForItem;
  final Function(String, bool) updateCart;
  final VoidCallback resetCartAndComponents;
  final VoidCallback clearCart;

  const CartModal({
    Key? key,
    required this.selectedItems,
    required this.getPriceForItem,
    required this.updateCart,
    required this.resetCartAndComponents,
    required this.clearCart,
  }) : super(key: key);

  @override
  _CartModalState createState() => _CartModalState();
}

class _CartModalState extends State<CartModal> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cart',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.selectedItems.length,
              itemBuilder: (BuildContext context, int index) {
                String itemName = widget.selectedItems.keys.elementAt(index);
                
                int quantity = widget.selectedItems[itemName]!;
                double totalPrice = widget.getPriceForItem(itemName) * quantity;

                return ListTile(
                  title: Text('$itemName x $quantity'),
                  subtitle: Text('Prijs: €$totalPrice'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        widget.updateCart(itemName, false); // Decrease quantity
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: widget.resetCartAndComponents,
                  child: const Text('Bevestig bestelling'),
                ),
                const SizedBox(width: 16.0), // Add space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
    );
  }
}
