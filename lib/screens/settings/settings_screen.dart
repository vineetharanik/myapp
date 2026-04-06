import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late LocalStorageService _localStorageService;
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from local storage
    final settings = await _localStorageService.getSettings();
    if (settings != null) {
      setState(() {
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
        _darkMode = settings['darkMode'] ?? true;
        _selectedLanguage = settings['language'] ?? 'English';
      });
    }
  }

  Future<void> _saveSettings() async {
    await _localStorageService.saveSettings({
      'notificationsEnabled': _notificationsEnabled,
      'darkMode': _darkMode,
      'language': _selectedLanguage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionCard(
              '👤 Profile Settings',
              'Manage your account information',
              Icons.person,
              Colors.blue,
              [
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Email',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _localStorageService.currentUser?['email'] ??
                        'Not logged in',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to profile edit
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to profile edit
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences
            _buildSectionCard(
              '⚙️ App Preferences',
              'Customize your app experience',
              Icons.settings,
              Colors.purple,
              [
                SwitchListTile(
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Get updates about your progress',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _notificationsEnabled,
                  activeColor: const Color(0xFF00D9FF),
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(color: Colors.white24),
                SwitchListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Reduce eye strain in low light',
                    style: TextStyle(color: Colors.white70),
                  ),
                  value: _darkMode,
                  activeColor: const Color(0xFF00D9FF),
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Language',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _selectedLanguage,
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Study Settings
            _buildSectionCard(
              '📚 Study Settings',
              'Configure your learning preferences',
              Icons.school,
              Colors.green,
              [
                ListTile(
                  leading: const Icon(Icons.schedule, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Study Reminders',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Daily study notifications',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to study reminders
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(
                    Icons.track_changes,
                    color: Color(0xFF00D9FF),
                  ),
                  title: const Text(
                    'Daily Goals',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Set daily study targets',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to goals settings
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Privacy
            _buildSectionCard(
              '🔒 Data & Privacy',
              'Manage your data and privacy',
              Icons.security,
              Colors.orange,
              [
                ListTile(
                  leading: const Icon(Icons.download, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Export Data',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Download your study data',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Clear Cache',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Free up storage space',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    _showClearCacheDialog();
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: Color(0xFF00D9FF),
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Learn about data usage',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionCard(
              'ℹ️ About',
              'App information and support',
              Icons.info,
              Colors.grey,
              [
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Version',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    '1.0.0',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.help, color: Color(0xFF00D9FF)),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Get help with the app',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // Navigate to help
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Logout Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Select Language',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Chinese']
              .map(
                (language) => RadioListTile<String>(
                  title: Text(
                    language,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: language,
                  groupValue: _selectedLanguage,
                  activeColor: const Color(0xFF00D9FF),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    _saveSettings();
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Export Data', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will export all your study data, journal entries, and progress. Do you want to continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data exported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Export',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear all cached data. You may need to download some content again. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement clear cache functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout? Your progress will be saved locally.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _localStorageService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
