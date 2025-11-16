import 'package:flutter/material.dart';
import '../services/recommendation_service.dart';
import '../models/food.dart';

/// Displays detailed product analysis including ingredients, allergens, and safety status
class ProductDetailsScreen extends StatefulWidget {
  final String productName;
  final List<String> ingredients;
  final List<String> allergens;
  final bool hasAllergen;
  final List<String> userAllergies;

  const ProductDetailsScreen({
    Key? key,
    required this.productName,
    required this.ingredients,
    required this.allergens,
    required this.hasAllergen,
    required this.userAllergies,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Map<String, dynamic>> _recommendationFuture;
  void initState() {
    super.initState();

    // 2. Call the API *one time* and save the "receipt" (the Future)
    _recommendationFuture = _getAlternativeProduct();
    
  }
    Future<Map<String, dynamic>> _getAlternativeProduct() async {
    final recommendationService = RecommendationService();
    try {
      final Food? alternative = await recommendationService.getRecommendation(
        "${widget.productName} (focus on name)",
        widget.userAllergies,
      );
      return alternative != null
          ? {
              'name': alternative.name,
              'description': "Safe alternative for ${widget.productName}",
            }
          : {};
    } catch (e) {
      print("Recommendation error: $e");
      return {};
    }
  }
  /// Fetches alternative product recommendations from external service


  @override
  Widget build(BuildContext context) {
    final Color safeColor = widget.hasAllergen ? Colors.red : Colors.green;
    final Color primaryColor = const Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details", 
            style: TextStyle(fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFF3E0)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImagePlaceholder(),
              const SizedBox(height: 32),
              _buildProductNameHeader(context),
              const SizedBox(height: 32),
              _buildIngredientsSection(),
              const SizedBox(height: 24),
              _buildAllergensSection(),
              const SizedBox(height: 32),
              _buildSafetyStatus(safeColor),
              const SizedBox(height: 32),
              if (widget.hasAllergen) _buildRecommendationSection(),
              const SizedBox(height: 24),
              _buildBackButton(primaryColor, context),
            ],
          ),
        ),
      ),
    );
  }

  /// Product image placeholder with camera icon
  Widget _buildProductImagePlaceholder() {
    return Center(
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
        )],
        ),
        child: Icon(
          Icons.camera_alt,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  /// Product name header with styling
  Widget _buildProductNameHeader(BuildContext context) {
    return Center(
      child: Text(
        widget.productName,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey[800]),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Scrollable ingredients list section
  Widget _buildIngredientsSection() {
    return _buildSectionCard(
      title: "Ingredients",
      icon: Icons.list_alt,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text("• $ingredient",
                  style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey[700])),
            )).toList(),
      ),
    );
  }

  /// Visual display of detected allergens using chips
  Widget _buildAllergensSection() {
    return _buildSectionCard(
      title: "Allergens Detected",
      icon: Icons.warning,
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.allergens.map((allergen) => Chip(
              label: Text(allergen,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            )).toList(),
      ),
    );
  }

  /// Safety status indicator with icon and gradient background
  Widget _buildSafetyStatus(Color safeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            safeColor.withOpacity(0.1),
            safeColor.withOpacity(0.05)],
        ),
      ),
      child: Column(
        children: [
          Icon(
            widget.hasAllergen ? Icons.dangerous : Icons.verified_user,
            color: safeColor,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            widget.hasAllergen ? "Not Safe" : "Safe!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: safeColor),
          ),
        ],
      ),
    );
  }

  /// Recommendation section with loading states
  Widget _buildRecommendationSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _recommendationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingRecommendation();
        }
        return _buildRecommendationCard(snapshot.data ?? {});
      },
    );
  }

  /// Navigation back button to scanner screen
  Widget _buildBackButton(Color primaryColor, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, size: 22),
        label: const Text("Back to Scanner"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  /// Standard section card template
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange[800], size: 24),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  /// Recommendation product display card
  Widget _buildRecommendationCard(Map<String, dynamic> alternative) {
    if (alternative.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend, color: Colors.green[800], size: 28),
              const SizedBox(width: 12),
              Text("Recommended Alternative",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800])),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.eco, color: Colors.green[800]),
            title: Text(alternative['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800])),
            subtitle: Text(alternative['description'],
                style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  /// Loading state indicator for recommendations
  Widget _buildLoadingRecommendation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Finding alternatives..."),
        ],
      ),
    );
  }
}