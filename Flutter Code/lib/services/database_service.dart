import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  
  // This is the "storage chest" for our products
  final Box _productBox = Hive.box('products');

  /// This function loads your entire JSON file into the Hive database.
  /// It only runs ONE TIME when the database is empty.
  Future<void> initProductDatabase() async {
    // Check if we've already run this
    if (_productBox.isNotEmpty) {
      print("Hive DB: Product database is already full.");
      return; 
    }

    // If it's empty, load the JSON file
    print("Hive DB: Loading products from JSON...");
    try {
      final jsonString = await rootBundle.loadString('assets/products.json');
      final List<dynamic> productList = json.decode(jsonString);

      // Loop through the JSON and save each product to Hive
      // We use the barcode as the 'key' (the ID). This makes lookups INSTANT.
      for (var product in productList) {
        if (product['barcode'] != null) {
          _productBox.put(product['barcode'], product);
        }
      }
      print("Hive DB: Product loading complete!");
    } catch (e) {
      print("Hive DB: Error loading product database: $e");
    }
  }

  /// This is your NEW, FAST lookup function.
  /// It replaces your old, slow `_loadProductDatabase`
  Map<String, dynamic>? getProductByBarcode(String barcode) {
    
    // This is an INSTANT lookup. No loops, no lag.
    final product = _productBox.get(barcode);

    if (product != null) {
      // Re-cast the data to the correct type and return it
      return Map<String, dynamic>.from(product as Map);
    }

    // Product not found
    return null; 
  }
}