import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class RecommendationService {
  final String apiUrl = 'http://192.168.157.242:5000/recommend';

  /// Sends a POST request to the API with the scanned text and user allergies.
  /// Returns a Food object parsed from the response.
  Future<Food?> getRecommendation(String scannedText, List<String> userAllergies) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "scanned_text": scannedText,
          "user_allergies": userAllergies,
        }),
      );

      print("API Response: ${response.body}"); // Debugging output

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Food.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      print("Exception in RecommendationService: $e");
      return null;
    }
  }
}
