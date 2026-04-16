import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String? errorText;
  final void Function(String)? onChanged;

  const PasswordInput({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.errorText,
    this.onChanged,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(fontSize: 14, color: Colors.black);
    final errorStyle = TextStyle(fontSize: 12, color: Colors.red[700]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: labelStyle),
            if (widget.isRequired)
              const Text('*', style: TextStyle(color: Colors.red)),
            const Spacer(),
            if (widget.errorText != null) Text('Required', style: errorStyle),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            errorText: widget.errorText,
            errorStyle: errorStyle,
          ),
        ),
      ],
    );
  }
}
