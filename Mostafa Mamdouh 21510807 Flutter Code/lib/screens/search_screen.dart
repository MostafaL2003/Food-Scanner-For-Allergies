import 'package:flutter/material.dart';
import '../models/food.dart';

class SearchScreen extends StatefulWidget {
  final List<Food> allFoods;
  final List<String> userAllergies;

  const SearchScreen({super.key, required this.allFoods, required this.userAllergies});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Food> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _filteredFoods = widget.allFoods;
  }

  void _filterResults(String query) {
    setState(() {
      _filteredFoods = widget.allFoods.where((food) {
        final matchesName = food.name.toLowerCase().contains(query.toLowerCase());
        return matchesName;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Food')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a food...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterResults,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  final isUnsafe = widget.userAllergies.any((allergy) => food.unsafeFor.contains(allergy));

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text('Calories: ${food.calories} kcal | Carbs: ${food.carbs}g'),
                      trailing: Icon(
                        isUnsafe ? Icons.warning : Icons.check_circle,
                        color: isUnsafe ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
