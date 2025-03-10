class AppConstants {
  // App info
  static const String appName = 'Comet';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Community sharing platform for gated communities';
  
  // Collection names
  static const String usersCollection = 'users';
  static const String itemsCollection = 'items';
  static const String communitiesCollection = 'communities';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String itemImagesPath = 'item_images';
  static const String communityImagesPath = 'community_images';
  
  // Validation
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int chatMessageMaxLength = 500;
  
  // Item request statuses
  static const String itemStatusPending = 'pending';
  static const String itemStatusAccepted = 'accepted';
  static const String itemStatusRejected = 'rejected';
  static const String itemStatusCompleted = 'completed';
  static const String itemStatusCancelled = 'cancelled';
  
  // Item categories
  static const List<String> itemCategories = [
    'Kitchen',
    'Electronics',
    'Furniture',
    'Books',
    'Clothing',
    'Tools',
    'Sports',
    'Toys',
    'Beauty',
    'Other',
  ];
  
  // Privacy policy URL
  static const String privacyPolicyUrl = 'https://comet-app.com/privacy-policy';
  
  // Terms of service URL
  static const String termsOfServiceUrl = 'https://comet-app.com/terms-of-service';
  
  // Support email
  static const String supportEmail = 'support@comet-app.com';
  
  // Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Maximum images per item
  static const int maxImagesPerItem = 5;
  
  // Default date format
  static const String defaultDateFormat = 'MMM dd, yyyy';
  
  // Default time format
  static const String defaultTimeFormat = 'hh:mm a';
}