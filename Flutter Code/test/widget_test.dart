
import 'package:flutter_test/flutter_test.dart';


import 'package:pleasegod/main.dart';

void main() {
  testWidgets('FoodSafetyApp loads correctly', (WidgetTester tester) async {
    // Build our app with required parameters
    await tester.pumpWidget(const FoodSafetyApp(
      userName: "Mostafa",
      userAllergies: ["Gluten", "Nuts"], // Sample allergies
    ));

    // Verify that the welcome message is displayed
    expect(find.text('Welcome, Mostafa'), findsOneWidget);
  });
}
