import 'package:flutter/material.dart';

import 'shopping_page.dart';

class MyApp extends StatelessWidget {
  final String jsonData = '''
  [
      "Heineken", {"id": 1, "prijs": 3.50, "asset_image": "assets/images/bier-heinkie.png"},
      "Heineken 0,0", {"id": 2, "prijs": 3.50, "asset_image": "assets/images/bier-heinkie-zero.png"},
      "Museum Hopper", {"id": 3, "prijs": 4.50, "asset_image": "assets/images/bier-hoppert.png"},
      "Texels", {"id": 4, "prijs": 4.50, "asset_image": "assets/images/bier-hoppert.png"},
      "Witte wijn", {"id": 5, "prijs": 4.50, "asset_image": "assets/images/wijn-wit.png"},
      "Rode wijn", {"id": 6, "prijs": 4.50, "asset_image": "assets/images/wijn-rood.png"},
      "Rosé", {"id": 7, "prijs": 4.50, "asset_image": "assets/images/wijn-rose.png"},
      "Pepsi", {"id": 8, "prijs": 3.00, "asset_image": "assets/images/pepsi-regular.png"},
      "Pepsi Zero", {"id": 9, "prijs": 3.00, "asset_image": "assets/images/pepsi-max.png"},
      "Sisi", {"id": 10, "prijs": 3.00, "asset_image": "assets/images/fanta.png"},
      "Lipton ice tea Sparkling", {"id": 11, "prijs": 3.00, "asset_image": "assets/images/lipton-blue.png"},
      "Lipton ice tea Green", {"id": 12, "prijs": 3.00, "asset_image": "assets/images/lipton-green.png"},
      "Sourcy Blauw", {"id": 13, "prijs": 3.00, "asset_image": "assets/images/sourcy-blauw.png"},
      "Sourcy Rood", {"id": 14, "prijs": 3.00, "asset_image": "assets/images/sourcy-rood.png"},
      "Appelsientje Sinaasappelsap", {"id": 15, "prijs": 3.00, "asset_image": "assets/images/appelsientje.png"},
      "Lay's chips Naturel 40gr", {"id": 16, "prijs": 1.50, "asset_image": "assets/images/chips-lays.png"},
      "Doritos chips Nacho cheese 44gr", {"id": 17, "prijs": 1.50, "asset_image": "assets/images/chips-rito.png"},
      "Vers afgebakken koek", {"id": 18, "prijs": 3.00, "asset_image": "assets/images/cookie.png"},
      "Muffin", {"id": 19, "prijs": 3.50, "asset_image": "assets/images/muffin.png"}
    ]
  ''';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(
        title: const Text(
          'Vermaat MenuMaster',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFB71C1C),
      ),
      body: ShoppingPage(
        jsonData: jsonData,
      ),
    );
  }
}
