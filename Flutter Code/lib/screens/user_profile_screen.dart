import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import 'home_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String currentName;
  final List<String> currentAllergies;

  const UserProfileScreen({
    Key? key,
    required this.currentName,
    required this.currentAllergies,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  final Set<String> _selectedAllergies = {};
  bool _isSaving = false;

  static const List<String> _allergyOptions = [
    'Wheat', 'Nuts', 'Milk', 'Shellfish', 'Soy', 'Eggs', 'Fish'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedAllergies.addAll(widget.currentAllergies);
  }

  Future<void> _saveAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    await LocalStorage.saveUserData(
      name: _nameController.text.trim(),
      allergies: _selectedAllergies.toList(),
    );

    if (!mounted) return;

    // ============== CRUCIAL FIX ==============
    if (Navigator.of(context).canPop()) {
      // When editing from HomeScreen - return to existing HomeScreen
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'allergies': _selectedAllergies.toList(),
      });
    } else {
      // First-time setup - replace with new HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: _nameController.text.trim(),
            userAllergies: _selectedAllergies.toList(),
          ),
        ),
      );
    }
    // ============== FIX ENDS HERE ==============
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildAllergyChip(String allergy) {
    final isSelected = _selectedAllergies.contains(allergy);
    return ChoiceChip(
      label: Text(allergy),
      selected: isSelected,
      onSelected: (selected) => setState(() {
        selected ? _selectedAllergies.add(allergy) 
                : _selectedAllergies.remove(allergy);
      }),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      selectedColor: Colors.orange[800],
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      avatar: isSelected
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'e.g. Alex Johnson',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18, 
                    horizontal: 20,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Select Your Allergies:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: _allergyOptions.map(_buildAllergyChip).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}