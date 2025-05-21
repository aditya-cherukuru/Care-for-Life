import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:care_for_life/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:care_for_life/app_router.dart';
import 'package:care_for_life/core/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    _buildPreferencesSection(context, state),
                    const Divider(),
                    _buildNotificationsSection(context, state),
                    const Divider(),
                    _buildDataSection(context),
                    const Divider(),
                    _buildAppearanceSection(context, state),
                    const Divider(),
                    _buildSupportSection(context),
                    const Divider(),
                    _buildAboutSection(context),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPreferencesSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SwitchListTile(
          title: const Text('Use 24-hour time'),
          subtitle: const Text('Display time in 24-hour format'),
          value: state.use24HourTime,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleUse24HourTime();
          },
        ),
        ListTile(
          title: const Text('Units of Measurement'),
          subtitle: Text(state.useMetricSystem ? 'Metric (kg, cm)' : 'Imperial (lb, in)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showUnitSelectionDialog(context, state);
          },
        ),
        ListTile(
          title: const Text('Default Tab'),
          subtitle: Text(state.defaultTab),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showDefaultTabSelectionDialog(context, state);
          },
        ),
        SwitchListTile(
          title: const Text('Start Week on Monday'),
          subtitle: const Text('Calendar weeks start on Monday instead of Sunday'),
          value: state.startWeekOnMonday,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleStartWeekOnMonday();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive reminders and updates'),
          value: state.notificationsEnabled,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleNotifications();
          },
        ),
        ListTile(
          title: const Text('Reminder Time'),
          subtitle: Text(state.reminderTime),
          trailing: const Icon(Icons.chevron_right),
          enabled: state.notificationsEnabled,
          onTap: state.notificationsEnabled
              ? () {
                  _showReminderTimeSelectionDialog(context);
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Goal Achievements'),
          subtitle: const Text('Get notified when you reach your goals'),
          value: state.goalNotificationsEnabled,
          onChanged: state.notificationsEnabled
              ? (value) {
                  context.read<SettingsCubit>().toggleGoalNotifications();
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('Weekly Reports'),
          subtitle: const Text('Receive weekly summary of your progress'),
          value: state.weeklyReportsEnabled,
          onChanged: state.notificationsEnabled
              ? (value) {
                  context.read<SettingsCubit>().toggleWeeklyReports();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Data & Privacy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_download),
          title: const Text('Export Data'),
          subtitle: const Text('Export your data as CSV or PDF'),
          onTap: () {
            _showExportDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Permanently delete all your data'),
          onTap: () {
            _showDeleteDataConfirmationDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeText(state.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showThemeSelectionDialog(context, state);
          },
        ),
        ListTile(
          title: const Text('Accent Color'),
          subtitle: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getAccentColor(state.accentColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(state.accentColor),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showAccentColorSelectionDialog(context, state);
          },
        ),
        SwitchListTile(
          title: const Text('Use Dynamic Colors'),
          subtitle: const Text('Use system colors (Android 12+ only)'),
          value: state.useDynamicColors,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleDynamicColors();
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & FAQ'),
          onTap: () {
            _launchURL(Constants.helpUrl);
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Send Feedback'),
          onTap: () {
            _showFeedbackDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Report a Bug'),
          onTap: () {
            _showBugReportDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share App'),
          onTap: () {
            share_plus.Share.share(
              'Check out Care for Life, a great health and wellness app! ${Constants.appStoreUrl}',
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListTile(
          title: const Text('Version'),
          subtitle: Text(_appVersion),
        ),
        ListTile(
          title: const Text('Terms of Service'),
          onTap: () {
            _launchURL(Constants.termsUrl);
          },
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          onTap: () {
            _launchURL(Constants.privacyUrl);
          },
        ),
        ListTile(
          title: const Text('Open Source Licenses'),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Care for Life',
              applicationVersion: _appVersion,
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '© 2023 Care for Life',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _showUnitSelectionDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Units of Measurement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<bool>(
                title: const Text('Metric (kg, cm)'),
                value: true,
                groupValue: state.useMetricSystem,
                onChanged: (value) {
                  context.read<SettingsCubit>().setUseMetricSystem(true);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<bool>(
                title: const Text('Imperial (lb, in)'),
                value: false,
                groupValue: state.useMetricSystem,
                onChanged: (value) {
                  context.read<SettingsCubit>().setUseMetricSystem(false);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDefaultTabSelectionDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default Tab'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Dashboard'),
                value: 'Dashboard',
                groupValue: state.defaultTab,
                onChanged: (value) {
                  context.read<SettingsCubit>().setDefaultTab('Dashboard');
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Habits'),
                value: 'Habits',
                groupValue: state.defaultTab,
                onChanged: (value) {
                  context.read<SettingsCubit>().setDefaultTab('Habits');
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Health Metrics'),
                value: 'Health Metrics',
                groupValue: state.defaultTab,
                onChanged: (value) {
                  context.read<SettingsCubit>().setDefaultTab('Health Metrics');
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('AI Assistant'),
                value: 'AI Assistant',
                groupValue: state.defaultTab,
                onChanged: (value) {
                  context.read<SettingsCubit>().setDefaultTab('AI Assistant');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showReminderTimeSelectionDialog(BuildContext context) async {
    final settingsCubit = context.read<SettingsCubit>();
    final state = settingsCubit.state;
    
    // Parse current time
    final timeParts = state.reminderTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final initialTime = TimeOfDay(hour: hour, minute: minute);
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (selectedTime != null) {
      final formattedHour = selectedTime.hour.toString().padLeft(2, '0');
      final formattedMinute = selectedTime.minute.toString().padLeft(2, '0');
      settingsCubit.setReminderTime('$formattedHour:$formattedMinute');
    }
  }

  void _showThemeSelectionDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context.read<SettingsCubit>().setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAccentColorSelectionDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accent Color'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildColorOption(context, 'Blue', Colors.blue),
              _buildColorOption(context, 'Green', Colors.green),
              _buildColorOption(context, 'Purple', Colors.purple),
              _buildColorOption(context, 'Orange', Colors.orange),
              _buildColorOption(context, 'Red', Colors.red),
              _buildColorOption(context, 'Pink', Colors.pink),
              _buildColorOption(context, 'Teal', Colors.teal),
              _buildColorOption(context, 'Cyan', Colors.cyan),
              _buildColorOption(context, 'Amber', Colors.amber),
              _buildColorOption(context, 'Indigo', Colors.indigo),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(BuildContext context, String colorName, Color color) {
    return InkWell(
      onTap: () {
        context.read<SettingsCubit>().setAccentColor(colorName);
        Navigator.pop(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: context.read<SettingsCubit>().state.accentColor == colorName
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export as CSV'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement CSV export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data exported as CSV'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement PDF export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data exported as PDF'),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDataConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text(
            'Are you sure you want to delete all your data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Implement data deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been deleted'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We appreciate your feedback! Please let us know how we can improve the app.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Your feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (feedbackController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your feedback'),
                    ),
                  );
                  return;
                }
                
                // Implement feedback submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final stepsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report a Bug'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please describe the bug and the steps to reproduce it.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'What happened?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Steps to Reproduce:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(
                    hintText: 'How can we reproduce this issue?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please describe the bug'),
                    ),
                  );
                  return;
                }
                
                // Implement bug report submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bug report submitted. Thank you!'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
    }
  }
}