import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'product_details_screen.dart';
import 'user_profile_screen.dart';
import 'scanner_screen.dart';
import '../widgets/action_buttons.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final List<String> userAllergies;

  const HomeScreen({
    Key? key,
    required this.userName,
    required this.userAllergies,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _userName;
  late List<String> _userAllergies;
  // ignore: unused_field
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userAllergies = widget.userAllergies;
  }

  Future<List<Map<String, dynamic>>> _loadProductDatabase() async {
    try {
      final jsonString = await rootBundle.loadString('assets/products.json');
      return List<Map<String, dynamic>>.from(json.decode(jsonString));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading product data")),
      );
      return [];
    }
  }

  void _handleScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(userAllergies: _userAllergies),
      ),
    );
  }

  Future<void> _handleUploadPhoto() async {
    try {
      final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile == null) return;

      final inputImage = InputImage.fromFile(File(xFile.path));
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No barcode found")),
        );
        return;
      }
      _processBarcode(barcodes.first.rawValue ?? "");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scanning failed")),
      );
    }
  }

  void _handleManualBarcodeEntry() {
    final enteredBarcode = _barcodeController.text.trim();
    if (enteredBarcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter barcode")),
      );
      return;
    }
    _processBarcode(enteredBarcode);
  }

  Future<void> _processBarcode(String barcode) async {
    setState(() => _isProcessing = true);
    try {
      final productDatabase = await _loadProductDatabase();
      final product = productDatabase.firstWhere(
        (prod) => prod["barcode"] == barcode,
        orElse: () => {},
      );

      if (product.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product not found")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            productName: product["name"] ?? "Unknown Product",
            ingredients: List<String>.from(product["ingredients"] ?? []),
            allergens: List<String>.from(product["allergens"] ?? []),
            hasAllergen: (List<String>.from(product["allergens"] ?? []))
                .any((allergen) => _userAllergies.contains(allergen)),
            userAllergies: _userAllergies,
          ),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    )),
            Text(_userName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () async {
              final updatedData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    currentName: _userName,
                    currentAllergies: _userAllergies,
                  ),
                ),
              );
              if (updatedData != null) {
                setState(() {
                  _userName = updatedData['name'];
                  _userAllergies = updatedData['allergies'];
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background.withOpacity(0.4),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Scan Product Barcode",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Check allergen safety instantly",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ActionButtons(
                        onScanPressed: _handleScan,
                        onUploadPressed: _handleUploadPhoto,
                      ),
                      const SizedBox(height: 32),
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey[300]!)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("or enter manually"),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300]!)),
                      ]),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.camera, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[500]),
                            onPressed: () => _barcodeController.clear(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: "EAN-13 Barcode",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleManualBarcodeEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text("Verify Product Safety"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}