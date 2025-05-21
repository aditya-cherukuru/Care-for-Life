import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:care_for_life/features/habit_tracker/presentation/cubit/habit_tracker_cubit.dart';
import 'package:care_for_life/features/health_metrices/presentation/cubit/health_metrics_cubit.dart';
import 'package:care_for_life/features/habit_tracker/data/repositories/habit_tracker_repository.dart';
import 'package:care_for_life/features/health_metrices/data/repositories/health_metrics_repository.dart';
import 'package:care_for_life/app_router.dart';
import 'package:care_for_life/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize repositories
  final habitTrackerRepository = HabitTrackerRepository();
  final healthMetricsRepository = HealthMetricsRepository();
  
  // Load initial data
  await habitTrackerRepository.loadHabits();
  await healthMetricsRepository.loadMetrics();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(),
        ),
        BlocProvider<HabitTrackerCubit>(
          create: (context) => HabitTrackerCubit(habitTrackerRepository),
        ),
        BlocProvider<HealthMetricsCubit>(
          create: (context) => HealthMetricsCubit(healthMetricsRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;
            
            if (settingsState.useDynamicColors && lightDynamic != null && darkDynamic != null) {
              // Use dynamic color scheme if available and enabled
              lightColorScheme = lightDynamic;
              darkColorScheme = darkDynamic;
            } else {
              // Otherwise use the selected accent color
              final Color primaryColor = _getAccentColor(settingsState.accentColor);
              
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: primaryColor,
                brightness: Brightness.light,
              );
              
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: primaryColor,
                brightness: Brightness.dark,
              );
            }
            
            return MaterialApp(
              title: Constants.appName,
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: lightColorScheme.primaryContainer,
                  foregroundColor: lightColorScheme.onPrimaryContainer,
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: darkColorScheme.primaryContainer,
                  foregroundColor: darkColorScheme.onPrimaryContainer,
                ),
              ),
              themeMode: settingsState.themeMode,
              home: const HomePage(),
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        );
      },
    );
  }
  
  Color _getAccentColor(String colorName) {
    switch (colorName) {
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Purple':
        return Colors.purple;
      case 'Orange':
        return Colors.orange;
      case 'Red':
        return Colors.red;
      case 'Pink':
        return Colors.pink;
      case 'Teal':
        return Colors.teal;
      case 'Cyan':
        return Colors.cyan;
      case 'Amber':
        return Colors.amber;
      case 'Indigo':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
    _setDefaultTab();
  }
  
  Future<void> _initializeData() async {
    // Load initial data for habit tracker
    context.read<HabitTrackerCubit>().loadHabits();
    
    // Load initial data for health metrics
    context.read<HealthMetricsCubit>().loadMetrics();
  }
  
  void _setDefaultTab() {
    final defaultTab = context.read<SettingsCubit>().state.defaultTab;
    
    switch (defaultTab) {
      case 'Dashboard':
        setState(() => _selectedIndex = 0);
        break;
      case 'Habits':
        setState(() => _selectedIndex = 1);
        break;
      case 'Health Metrics':
        setState(() => _selectedIndex = 2);
        break;
      case 'AI Assistant':
        setState(() => _selectedIndex = 3);
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const DashboardPage(),
          AppRouter.habitTrackerPage(),
          AppRouter.healthMetricsPage(),
          const AiAssistantPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Metrics',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}

// Placeholder for Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigateToSettings(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Care for Life',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your health and wellness companion',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                AppRouter.navigateToHabitTracker(context);
              },
              child: const Text('Track Habits'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppRouter.navigateToHealthMetrics(context);
              },
              child: const Text('View Health Metrics'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for AI Assistant Page
class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.navigateToSettings(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_toy,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Health Assistant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Get personalized health insights and recommendations based on your habits and metrics.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Start Conversation'),
              onPressed: () {
                // TODO: Implement AI chat functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI Assistant coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}