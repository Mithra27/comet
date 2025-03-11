import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool disabled;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(
          backgroundColor: AppConstants.colors.primary,
          foregroundColor: Colors.white,
        );
      case ButtonType.secondary:
        return _buildElevatedButton(
          backgroundColor: AppConstants.colors.secondary,
          foregroundColor: Colors.white,
        );
      case ButtonType.outline:
        return _buildOutlinedButton();
      case ButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(foregroundColor),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppConstants.colors.primary,
        padding: _getPadding(),
        side: BorderSide(color: AppConstants.colors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(AppConstants.colors.primary),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.colors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildButtonContent(AppConstants.colors.primary),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: _getFontSize() * 1.5,
        width: _getFontSize() * 1.5,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getFontSize() * 1.2),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}