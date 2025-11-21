import 'package:flutter/material.dart';

// No need to import phone field here, just pass as child if needed

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? child; // Add this line!

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.isPassword,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.child, // Add this line!
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      // If child is passed (like IntlPhoneField), just show label + child
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          child!,
          const SizedBox(height: 12),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onTap, // Calendar tap etc.
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
