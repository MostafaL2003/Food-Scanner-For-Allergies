import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'product_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  final List<String> userAllergies;
  const ScannerScreen({Key? key, required this.userAllergies}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String barcodeResult = 'No barcode detected';
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false; // Added flag to block duplicate scans

  // Load the products database from assets. (No changes here)
  Future<List<Map<String, dynamic>>> _loadProductDatabase() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/products.json');
      return List<Map<String, dynamic>>.from(json.decode(jsonString));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading product data.")),
      );
      return [];
    }
  }

  // Process barcode (No changes here except async/await)
  Future<void> _processBarcode(String scannedBarcode) async {
    try {
      final productDatabase = await _loadProductDatabase();
      final product = productDatabase.isNotEmpty
          ? productDatabase.firstWhere(
              (prod) => prod["barcode"] == scannedBarcode,
              orElse: () => {},
            )
          : null;

      if (product == null || product.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product not found.")),
        );
        return;
      }

      // Navigate to details screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productName: product["name"] ?? "Unknown Product",
            ingredients: List<String>.from(product["ingredients"] ?? []),
            allergens: List<String>.from(product["allergens"] ?? []),
            hasAllergen: (List<String>.from(product["allergens"] ?? []))
                .any((allergen) => widget.userAllergies.contains(allergen)),
            userAllergies: widget.userAllergies,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing barcode.")),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose controller properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barcode Scanner")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture capture) async {
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty || _isProcessing) return; // Block duplicates

                final code = barcodes.first.rawValue ?? "";
                if (code.isEmpty) return;

                setState(() => barcodeResult = code);

                // Stop scanner and block processing
                await controller.stop();
                setState(() => _isProcessing = true);

                // Process and restart when returning
                await _processBarcode(code);
                if (mounted) {
                  await controller.start();
                  setState(() => _isProcessing = false);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text("Result: $barcodeResult", style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}