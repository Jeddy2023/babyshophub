import 'package:flutter/material.dart';

enum ButtonSize { full, medium, small }

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isLoading;
  final Color backgroundColor;
  final Widget? leadingIcon;
  final ButtonSize buttonSize;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF1565C0),
    this.leadingIcon,
    this.buttonSize = ButtonSize.full,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    double buttonWidth;

    switch (buttonSize) {
      case ButtonSize.full:
        buttonWidth = double.infinity;
        break;
      case ButtonSize.medium:
        buttonWidth = MediaQuery.of(context).size.width * 0.6;
        break;
      case ButtonSize.small:
        buttonWidth = MediaQuery.of(context).size.width * 0.3;
        break;
    }

    return SizedBox(
      width: buttonWidth,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              buttonText,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
