import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pleasegod/cubit/profile_cubit.dart';
import 'package:pleasegod/screens/home_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  final Set<String> _selectedAllergies = {};
  bool _isSaving = false;

  static const List<String> _allergyOptions = [
    'Wheat',
    'Nuts',
    'Milk',
    'Shellfish',
    'Soy',
    'Eggs',
    'Fish',
  ];

  @override
  void initState() {
    super.initState();
    final initialState = context.read<ProfileCubit>().state;
    _nameController = TextEditingController(text: initialState.userName);
    _selectedAllergies.addAll(initialState.userAllergies);
  }

  Future<void> _saveAndContinue() async {
    // 1. Validate the form
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isSaving = true);

    // 2. Tell the "brain" (Cubit) to update and save the data
    await context.read<ProfileCubit>().updateProfile(
      _nameController.text.trim(),
      _selectedAllergies.toList(),
    );

    if (!mounted) return;

    // 3. This is the smart navigation logic we're restoring:
    //
    // Check: "Can I go back?" (e.g., Was I pushed here from HomeScreen?)
    if (Navigator.of(context).canPop()) {
      // If YES: Just go back. The HomeScreen is already listening.
      Navigator.pop(context);
    } else {
      // If NO: This is the first-time setup.
      // We must *replace* the setup screen with the main app.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // We don't pass any data. HomeScreen will
          // get the new profile from the Cubit.
          builder: (context) => HomeScreen(),
        ),
      );
    }
  } // When editing from HomeScreen - return to existing HomeScreen

  // ============== FIX ENDS HERE ==============

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
      onSelected:
          (selected) => setState(() {
            selected
                ? _selectedAllergies.add(allergy)
                : _selectedAllergies.remove(allergy);
          }),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      selectedColor: Colors.orange[800],
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      avatar:
          isSelected
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile'), elevation: 4),
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
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.orange,
                  ),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                  child:
                      _isSaving
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
