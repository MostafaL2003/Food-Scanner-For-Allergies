// Represents a food item with details like name, allergens, and nutritional values.
class Food {
  final String name;
  final List<String> unsafeFor; // Allergens present in the food
  final int calories;
  final int carbs;
// Constructor: Initializes a food item with name, allergens, and nutritional data.
  Food({
    required this.name,
    required this.unsafeFor,
    required this.calories,
    required this.carbs,
  });
// Factory constructor: Converts a JSON map into a Food object.
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'] as String,
      unsafeFor: List<String>.from(json['unsafeFor'] ?? []),
      calories: json['calories'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
    );
  }
}
