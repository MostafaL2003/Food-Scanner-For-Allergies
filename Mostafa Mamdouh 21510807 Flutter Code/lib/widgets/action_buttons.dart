import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onUploadPressed;

  const ActionButtons({
    Key? key,
    required this.onScanPressed,
    required this.onUploadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Scan Button
        ElevatedButton.icon(
          onPressed: onScanPressed,
          icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
          label: const Text(
            "Start Scanning",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            elevation: 6,
            shadowColor: Colors.blue.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 1.5,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ).copyWith(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.9);
                }
                return Theme.of(context).colorScheme.primary;
              },
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Upload Button
        ElevatedButton.icon(
          onPressed: onUploadPressed,
          icon: const Icon(Icons.upload_file, size: 28, color: Colors.white),
          label: const Text(
            "Upload Photo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            elevation: 6,
            shadowColor: Colors.purple.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                width: 1.5,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ).copyWith(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return Theme.of(context).colorScheme.secondary.withOpacity(0.9);
                }
                return Theme.of(context).colorScheme.secondary;
              },
            ),
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}