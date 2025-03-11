import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 36.0,
    this.color = Colors.blue, // Changed from AppConstants.primaryColor to a direct color
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3.0,
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: LoadingIndicator(message: message),
            ),
          ),
      ],
    );
  }
}