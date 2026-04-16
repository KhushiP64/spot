import 'package:flutter/material.dart';
import 'package:spot/core/themes.dart';

class PasswordRuleItem extends StatelessWidget {
  final String text;
  final bool passed;

  const PasswordRuleItem(this.text, this.passed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(passed ? Icons.check : Icons.close,
            color: passed ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 6),
        Flexible(
            child: Text(text,
                style: AppFontStyles.dmSansMedium.copyWith(
                  overflow: TextOverflow.clip,
                  color: passed ? Colors.green : Colors.red,
                  fontSize: 13,
                ))),
      ],
    );
  }
}
