import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class DataViewerScreen extends StatefulWidget {
  const DataViewerScreen({super.key});

  @override
  State<DataViewerScreen> createState() => _DataViewerScreenState();
}

class _DataViewerScreenState extends State<DataViewerScreen> {
  late LocalStorageService _localStorageService;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allJournalEntries = [];
  List<Map<String, dynamic>> _allChatMessages = [];
  bool _isLoading = false;
  String _selectedView = 'users'; // users, activities, journals, chats

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _localStorageService.initialize();

      // Get all users
      final users = _localStorageService.prefs?.getStringList('users') ?? [];
      _allUsers = users
          .map((userJson) {
            try {
              return jsonDecode(userJson) as Map<String, dynamic>;
            } catch (e) {
              print('Error decoding user: $e');
              return <String, dynamic>{};
            }
          })
          .where((user) => user.isNotEmpty)
          .toList();

      // Get all journal entries from all users
      _allJournalEntries = [];
      for (final user in _allUsers) {
        final userId = user['id'] as String?;
        if (userId != null) {
          final journals = await _localStorageService.getJournalHistory(userId);
          _allJournalEntries.addAll(
            journals.map(
              (journal) => {
                ...journal,
                'userId': userId,
                'userName': user['name'] ?? user['email'] ?? 'Unknown',
                'userEmail': user['email'] ?? 'Unknown',
              },
            ),
          );
        }
      }

      // Get all chat messages from all users
      _allChatMessages = [];
      for (final user in _allUsers) {
        final userId = user['id'] as String?;
        if (userId != null) {
          final chats = await _localStorageService.getChatHistory(userId);
          _allChatMessages.addAll(
            chats.map(
              (chat) => {
                ...chat,
                'userId': userId,
                'userName': user['name'] ?? user['email'] ?? 'Unknown',
                'userEmail': user['email'] ?? 'Unknown',
              },
            ),
          );
        }
      }

      // Sort activities by timestamp
      _allJournalEntries.sort((a, b) {
        final aTime = a['timestamp'] as String? ?? '';
        final bTime = b['timestamp'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      _allChatMessages.sort((a, b) {
        final aTime = a['timestamp'] as String? ?? '';
        final bTime = b['timestamp'] as String? ?? '';
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Delete All Data'),
        content: const Text(
          'This will permanently delete ALL user data including profiles, journals, and activities. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _localStorageService.clearAllData();
      setState(() {
        _allUsers = [];
        _allJournalEntries = [];
        _allChatMessages = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNavigationTabs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('users', '👥 Users', Icons.people)),
          Expanded(
            child: _buildTabButton(
              'activities',
              '📊 Activities',
              Icons.timeline,
            ),
          ),
          Expanded(
            child: _buildTabButton('journals', '📝 Journals', Icons.book),
          ),
          Expanded(child: _buildTabButton('chats', '💬 Chats', Icons.chat)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String view, String title, IconData icon) {
    final isSelected = _selectedView == view;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = view),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00D9FF).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D9FF) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00D9FF)
                  : Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00D9FF)
                    : Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersView() {
    return Column(
      children: [
        _buildStatsCard(),
        const SizedBox(height: 16),
        ..._allUsers.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withOpacity(0.2),
            const Color(0xFF00D9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Admin Dashboard Statistics',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('👥', 'Total Users', '${_allUsers.length}'),
              _buildStatItem(
                '📝',
                'Journal Entries',
                '${_allJournalEntries.length}',
              ),
              _buildStatItem(
                '💬',
                'Chat Messages',
                '${_allChatMessages.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id'] as String? ?? '';
    final userName =
        user['name'] as String? ?? user['email'] as String? ?? 'Unknown';
    final userEmail = user['email'] as String? ?? 'Unknown';
    final createdAt = user['createdAt'] as String? ?? '';
    final skills = (user['skills'] as List?)?.cast<String>() ?? <String>[];

    // Count user's activities
    final userJournals = _allJournalEntries
        .where((j) => j['userId'] == userId)
        .length;
    final userChats = _allChatMessages
        .where((c) => c['userId'] == userId)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // User Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00D9FF).withOpacity(0.2),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xFF00D9FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (createdAt.isNotEmpty)
                        Text(
                          'Joined: ${_formatDate(createdAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$userJournals journals',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$userChats chats',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (skills.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.code, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Skills:',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: skills
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    skill,
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Recent Activity Preview
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Activity:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRecentActivityPreview(userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityPreview(String userId) {
    final userJournals = _allJournalEntries
        .where((j) => j['userId'] == userId)
        .take(3)
        .toList();

    if (userJournals.isEmpty) {
      return Text(
        'No recent activity',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      children: userJournals.map((journal) {
        final timestamp = journal['timestamp'] as String? ?? '';
        final analysis = journal['analysis'] as Map<String, dynamic>?;
        final mood = analysis?['mood'] as String? ?? 'Unknown';

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.mood, color: _getMoodColor(mood), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatDate(timestamp)} - Mood: $mood',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivitiesView() {
    final allActivities = [
      ..._allJournalEntries.map((j) => {...j, 'type': 'journal'}),
      ..._allChatMessages.map((c) => {...c, 'type': 'chat'}),
    ];

    allActivities.sort((a, b) {
      final aTime = a['timestamp'] as String? ?? '';
      final bTime = b['timestamp'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.timeline, color: const Color(0xFF00D9FF)),
              const SizedBox(width: 12),
              Text(
                '📈 All User Activities (${allActivities.length})',
                style: const TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...allActivities
            .take(20)
            .map((activity) => _buildActivityCard(activity))
            ,
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final type = activity['type'] as String? ?? 'unknown';
    final userName = activity['userName'] as String? ?? 'Unknown';
    final userEmail = activity['userEmail'] as String? ?? 'Unknown';
    final timestamp = activity['timestamp'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: type == 'journal'
                      ? Colors.purple.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type == 'journal' ? '📝 Journal' : '💬 Chat',
                  style: TextStyle(
                    color: type == 'journal' ? Colors.purple : Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (type == 'journal')
            _buildJournalActivityContent(activity)
          else
            _buildChatActivityContent(activity),
        ],
      ),
    );
  }

  Widget _buildJournalActivityContent(Map<String, dynamic> journal) {
    final analysis = journal['analysis'] as Map<String, dynamic>?;
    if (analysis == null) {
      return Text(
        'No analysis data available',
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analysis['summary'] != null) ...[
            Text(
              '📋 ${analysis['summary']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              _buildActivityBadge('Mood', '${analysis['mood']}', Colors.green),
              const SizedBox(width: 8),
              _buildActivityBadge(
                'Burnout',
                '${analysis['burnout_risk']}%',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildActivityBadge(
                'Problems',
                '${analysis['problems_solved_today']}',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatActivityContent(Map<String, dynamic> chat) {
    final message = chat['message'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.chat, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.length > 100
                  ? '${message.substring(0, 100)}...'
                  : message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJournalsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.book, color: Colors.purple),
              const SizedBox(width: 12),
              Text(
                '📝 All Journal Entries (${_allJournalEntries.length})',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._allJournalEntries
            .take(15)
            .map((journal) => _buildDetailedJournalCard(journal))
            ,
      ],
    );
  }

  Widget _buildDetailedJournalCard(Map<String, dynamic> journal) {
    final userName = journal['userName'] as String? ?? 'Unknown';
    final timestamp = journal['timestamp'] as String? ?? '';
    final analysis = journal['analysis'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Journal Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.book, color: Colors.purple),
              ],
            ),
          ),

          // Journal Content
          if (analysis != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (analysis['summary'] != null) ...[
                    Text(
                      '📋 Summary',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis['summary'],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: _buildJournalMetric(
                          'Mood',
                          '${analysis['mood']}',
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildJournalMetric(
                          'Burnout Risk',
                          '${analysis['burnout_risk']}%',
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildJournalMetric(
                          'Problems Solved',
                          '${analysis['problems_solved_today']}',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  if (analysis['recommendations'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '💡 Recommendations',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...((analysis['recommendations'] as List?)
                            ?.take(2)
                            .map(
                              (rec) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_right,
                                      color: Colors.purple,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rec.toString(),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ) ??
                        []),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJournalMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.chat, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                '💬 All Chat Messages (${_allChatMessages.length})',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._allChatMessages
            .take(15)
            .map((chat) => _buildChatCard(chat))
            ,
      ],
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final userName = chat['userName'] as String? ?? 'Unknown';
    final message = chat['message'] as String? ?? '';
    final timestamp = chat['timestamp'] as String? ?? '';
    final isBot = chat['isBot'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isBot ? Colors.blue : Colors.green,
            radius: 16,
            child: Icon(
              isBot ? Icons.smart_toy : Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isBot ? 'AI Assistant' : userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
        return Colors.yellow;
      case 'focused':
      case 'productive':
        return Colors.green;
      case 'tired':
      case 'stressed':
        return Colors.orange;
      case 'sad':
      case 'anxious':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Color(0xFF00D9FF)),
            const SizedBox(width: 12),
            const Text(
              '🔧 Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            onPressed: _clearAllData,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNavigationTabs(),
                  const SizedBox(height: 20),
                  if (_selectedView == 'users')
                    _buildUsersView()
                  else if (_selectedView == 'activities')
                    _buildActivitiesView()
                  else if (_selectedView == 'journals')
                    _buildJournalsView()
                  else if (_selectedView == 'chats')
                    _buildChatsView(),
                ],
              ),
            ),
    );
  }
}
