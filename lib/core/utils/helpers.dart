import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:comet/core/constants/app_constants.dart';
import 'package:flutter/services.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.defaultDateFormat).format(date);
  }
  
  // Format time
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.defaultTimeFormat).format(time);
  }
  
  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }
  
  // Get relative time (e.g., "3 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Launch URL
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
  
  // Launch email
  static Future<void> launchEmail(String email, {String subject = '', String body = ''}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    
    if (!await launchUrl(emailUri)) {
      throw 'Could not launch email to $email';
    }
  }
  
  // Launch phone call
  static Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (!await launchUrl(phoneUri)) {
      throw 'Could not launch phone call to $phoneNumber';
    }
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text, {String? message}) async {
    await Clipboard.setData(ClipboardData(text: text));
    showSnackBar(context, message ?? 'Copied to clipboard');
  }
  
  // Get initials from name
  static String getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';
    
    if (nameParts.isNotEmpty) {
      if (nameParts.length > 1) {
        initials = nameParts[0][0] + nameParts[1][0];
      } else {
        initials = nameParts[0][0];
      }
    }
    
    return initials.toUpperCase();
  }
  
  // Get color from string (for avatars)
  static Color getColorFromString(String input) {
    final colors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.red.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
      Colors.indigo.shade300,
      Colors.pink.shade300,
      Colors.amber.shade300,
      Colors.cyan.shade300,
    ];
    
    // Simple hash function to get index
    int hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    return colors[hash.abs() % colors.length];
  }
  
  // Format number with commas
  static String formatNumberWithCommas(int number) {
    return NumberFormat('#,###').format(number);
  }
}