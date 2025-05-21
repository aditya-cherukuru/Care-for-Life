import 'package:flutter/material.dart';
import 'package:care_for_life/features/home/presentation/pages/home_page.dart';
import 'package:care_for_life/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:care_for_life/features/habit_tracker/presentation/pages/habit_tracker_page.dart';
import 'package:care_for_life/features/habit_tracker/presentation/pages/habit_detail_page.dart';
import 'package:care_for_life/features/health_metrices/presentation/pages/health_metrics_page.dart';
import 'package:care_for_life/features/health_metrices/presentation/pages/metric_detail_page.dart';
import 'package:care_for_life/features/settings/presentation/pages/settings_page.dart';
import 'package:care_for_life/features/imprint/presentation/pages/imprint_page.dart';
// import 'package:care_for_life/features/existing_feature/integration.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String existingFeatureRoute = '/existing-feature';
  static const String chatbotRoute = '/chatbot';
  static const String habitTrackerRoute = '/habit-tracker';
  static const String habitDetailRoute = '/habit-detail';
  static const String healthMetricsRoute = '/health-metrics';
  static const String metricDetailRoute = '/metric-detail';
  static const String settingsRoute = '/settings';
  static const String imprintRoute = '/imprint';

  
  static void navigateToHabitDetail(BuildContext context, String habitId) {
    Navigator.pushNamed(
      context,
      habitDetailRoute, // Changed from '/habit_detail' to use the constant
      arguments: habitId,
    );
  }

  static void navigateToMetricDetail(BuildContext context, String metricId) {
    Navigator.pushNamed(
      context,
      metricDetailRoute, // Using the constant for consistency
      arguments: metricId,
    );
  }

  // Navigation methods
  static void navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  static void navigateToHabitTracker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => habitTrackerPage()),
    );
  }

  static void navigateToHealthMetrics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => healthMetricsPage()),
    );
  }

  // Page factory methods
  static Widget habitTrackerPage() {
    return const HabitTrackerPage();
  }

  static Widget healthMetricsPage() {
    return const HealthMetricsPage();
  }


  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case chatbotRoute:
        return MaterialPageRoute(builder: (_) => const ChatbotPage());
      case habitTrackerRoute:
        return MaterialPageRoute(builder: (_) => const HabitTrackerPage());
      case habitDetailRoute:
        final habitId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => HabitDetailPage(habitId: habitId),
        );
      case healthMetricsRoute:
        return MaterialPageRoute(builder: (_) => const HealthMetricsPage());
      case metricDetailRoute:
        final metricId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MetricDetailPage(metricId: metricId),
        );
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case imprintRoute:
        return MaterialPageRoute(builder: (_) => const ImprintPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}