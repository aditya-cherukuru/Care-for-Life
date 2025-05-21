class AppConstants {
  // API Keys
  static const String geminiApiKey = String.fromEnvironment('AIzaSyDau04tjtsJVImN_ZYDXtDU8rXNQ5JWW7Q');
  
  // API Endpoints
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // App Info
  static const String appName = 'Care for Life';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A health & habits app to help people care about their life and develop healthy habits.';
  
  // Navigation
  static const int homeNavIndex = 0;
  static const int habitTrackerNavIndex = 1;
  static const int chatbotNavIndex = 2;
  static const int healthMetricsNavIndex = 3;
  
  // Default Values
  static const List<String> defaultHabitCategories = [
    'Exercise',
    'Nutrition',
    'Sleep',
    'Mindfulness',
    'Hydration',
    'Productivity',
  ];
  
  // Contact Info (for Imprint)
  static const String developerName = 'Aditya Cherukuru';
  static const String developerEmail = 'your.email@example.com';
  static const String developerWebsite = 'https://github.com/aditya-cherukuru';
}

class Constants {
  // App URLs
  static const String appStoreUrl = 'https://play.google.com/store/apps/details?id=com.careforlife.app';
  static const String helpUrl = 'https://careforlife.app/help';
  static const String termsUrl = 'https://careforlife.app/terms';
  static const String privacyUrl = 'https://careforlife.app/privacy';
  
  // API Keys and Endpoints
  static const String apiBaseUrl = 'https://api.careforlife.app/v1';
  
  // Feature Flags
  static const bool enableAIAssistant = true;
  static const bool enableCloudSync = true;
  static const bool enablePremiumFeatures = true;
  
  // Default Values
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;
  
  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  
  // Notification Channels
  static const String reminderChannelId = 'reminders';
  static const String reminderChannelName = 'Reminders';
  static const String reminderChannelDescription = 'Daily reminders for tracking habits and metrics';
  
  static const String goalChannelId = 'goals';
  static const String goalChannelName = 'Goal Achievements';
  static const String goalChannelDescription = 'Notifications for goal achievements';
  
  static const String reportChannelId = 'reports';
  static const String reportChannelName = 'Weekly Reports';
  static const String reportChannelDescription = 'Weekly summary reports';
  
  // App Constants
  static const String appName = 'Care for Life';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Cache Duration
  static const int cacheDuration = 86400; // 24 hours in seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Animation Durations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int mediumAnimationDuration = 300; // milliseconds
  static const int longAnimationDuration = 500; // milliseconds
  
  // Minimum Password Length
  static const int minPasswordLength = 8;
  
  // Maximum Values
  static const int maxHabitsPerDay = 20;
  static const int maxMetricsPerUser = 50;
  static const int maxEntriesPerMetric = 1000;
  
  // Default Chart Ranges
  static const int defaultChartDays = 30;
  
  // Gemini API
  static const String geminiApiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
 // Private constructor to prevent instantiation
}