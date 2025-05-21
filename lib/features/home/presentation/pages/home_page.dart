import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/app_router.dart';
import 'package:care_for_life/core/theme/theme_cubit.dart';
import 'package:care_for_life/core/utils/constants.dart';
import 'package:care_for_life/features/home/presentation/widgets/habit_list_item.dart';
import 'package:care_for_life/features/home/presentation/widgets/health_tip_card.dart';
import 'package:care_for_life/features/home/data/models/habit.dart';
import 'package:care_for_life/features/home/data/models/health_tip.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Sample data - in a real app, this would come from a repository
  final List<Habit> _habits = [
    Habit(
      id: '1',
      title: 'Morning Walk',
      description: 'Take a 30-minute walk every morning',
      category: 'Exercise',
      iconData: Icons.directions_walk,
    ),
    Habit(
      id: '2',
      title: 'Drink Water',
      description: 'Drink 8 glasses of water daily',
      category: 'Hydration',
      iconData: Icons.water_drop,
    ),
    Habit(
      id: '3',
      title: 'Meditation',
      description: '10 minutes of mindfulness meditation',
      category: 'Mindfulness',
      iconData: Icons.self_improvement,
    ),
    Habit(
      id: '4',
      title: 'Healthy Breakfast',
      description: 'Start your day with a nutritious breakfast',
      category: 'Nutrition',
      iconData: Icons.breakfast_dining,
    ),
    Habit(
      id: '5',
      title: 'Sleep Schedule',
      description: 'Go to bed and wake up at consistent times',
      category: 'Sleep',
      iconData: Icons.bedtime,
    ),
  ];
  
  final List<HealthTip> _healthTips = [
    HealthTip(
      id: '1',
      title: 'Stay Hydrated',
      content: 'Drinking enough water is crucial for your health. Aim for 8 glasses a day.',
      imageUrl: 'https://images.unsplash.com/photo-1559839914-17aae19cec71',
    ),
    HealthTip(
      id: '2',
      title: 'Regular Exercise',
      content: 'Just 30 minutes of moderate exercise each day can significantly improve your health.',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
    ),
    HealthTip(
      id: '3',
      title: 'Mindful Eating',
      content: 'Pay attention to what and when you eat. Avoid distractions like TV during meals.',
      imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352',
    ),
  ];
  
  List<Habit> _filteredHabits = [];
  
  @override
  void initState() {
    super.initState();
    _filteredHabits = _habits;
    _searchController.addListener(_filterHabits);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterHabits() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredHabits = _habits;
      });
    } else {
      setState(() {
        _filteredHabits = _habits
            .where((habit) => habit.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                habit.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                habit.category.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care for Life'),
        actions: [
          IconButton(
            icon: Icon(
              context.read<ThemeCubit>().state.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.habitTrackerRoute);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Habit',
      ),
    );
  }
  
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Existing Feature'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.existingFeatureRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Health Assistant'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.chatbotRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Habit Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.habitTrackerRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Health Metrics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.healthMetricsRoute);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.settingsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Imprint'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.imprintRoute);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search habits...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Health Tips Section
            Text(
              'Health Tips',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _healthTips.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: HealthTipCard(
                      healthTip: _healthTips[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Habits Section
            Text(
              'Recommended Habits',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredHabits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HabitListItem(
                    habit: _filteredHabits[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.habitDetailRoute,
                        arguments: _filteredHabits[index].id,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        switch (index) {
          case AppConstants.homeNavIndex:
            Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
            break;
          case AppConstants.habitTrackerNavIndex:
            Navigator.pushNamed(context, AppRouter.habitTrackerRoute);
            break;
          case AppConstants.chatbotNavIndex:
            Navigator.pushNamed(context, AppRouter.chatbotRoute);
            break;
          case AppConstants.healthMetricsNavIndex:
            Navigator.pushNamed(context, AppRouter.healthMetricsRoute);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Habits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Assistant',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Metrics',
        ),
      ],
    );
  }
}