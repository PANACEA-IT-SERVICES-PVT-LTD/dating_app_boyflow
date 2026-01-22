import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/api_controller.dart';

// Call History Item Model
class CallHistoryItem {
  final String userId;
  final String name;
  final String profileImage;
  final String callType;
  final String status;
  final int duration;
  final int billableDuration;
  final DateTime createdAt;
  final String callId;

  CallHistoryItem({
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.callType,
    required this.status,
    required this.duration,
    required this.billableDuration,
    required this.createdAt,
    required this.callId,
  });

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown',
      profileImage: json['profileImage'] ?? '',
      callType: json['callType'] ?? 'audio',
      status: json['status'] ?? 'unknown',
      duration: json['duration'] ?? 0,
      billableDuration: json['billableDuration'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      callId: json['callId'] ?? '',
    );
  }
}

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  List<CallHistoryItem> _callHistory = [];
  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _error;

  int _currentPage = 0;
  bool _hasMore = true;

  // Call stats
  int _totalCalls = 0;
  int _totalDuration = 0;
  int _totalCoinsSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
    _loadCallStats();
  }

  Future<void> _loadCallHistory({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (!loadMore) {
        _error = null;
        _currentPage = 0;
        _callHistory.clear();
      }
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final result = await apiController.fetchCallHistory(
        limit: 10,
        skip: _currentPage * 10,
      );

      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> data = result['data'];
        final List<CallHistoryItem> newItems = data
            .map((item) => CallHistoryItem.fromJson(item))
            .toList();

        setState(() {
          if (loadMore) {
            _callHistory.addAll(newItems);
          } else {
            _callHistory = newItems;
          }
          _hasMore = newItems.length == 10; // Assume more if we got full page
          _currentPage++;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load call history';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCallStats() async {
    if (_isLoadingStats) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      final apiController = Provider.of<ApiController>(context, listen: false);
      final result = await apiController.fetchCallStats();

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        setState(() {
          _totalCalls = data['totalCalls'] ?? 0;
          _totalDuration = data['totalDuration'] ?? 0;
          _totalCoinsSpent = data['totalCoinsSpent'] ?? 0;
        });
      }
    } catch (e) {
      // Optionally handle the error if needed
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Call History",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadCallHistory(),
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadCallHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Stats header
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$_totalCalls',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Total Calls',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              _formatDuration(_totalDuration),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Total Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '$_totalCoinsSpent',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Coins Spent',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Call history list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      itemCount: _callHistory.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _callHistory.length) {
                          // Load more indicator
                          return _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : ListTile(
                                  title: const Text('Load More'),
                                  onTap: () => _loadCallHistory(loadMore: true),
                                  trailing: const Icon(Icons.arrow_downward),
                                );
                        }

                        final call = _callHistory[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: call.profileImage.isNotEmpty
                                  ? NetworkImage(call.profileImage)
                                  : null,
                              child: call.profileImage.isEmpty
                                  ? Text(call.name.substring(0, 1))
                                  : null,
                            ),
                            title: Text(call.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      call.callType == 'video'
                                          ? Icons.videocam
                                          : Icons.phone,
                                      size: 16,
                                      color: call.callType == 'video'
                                          ? Colors.pink
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${call.callType.capitalize()} call',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: call.status == 'completed'
                                            ? Colors.green
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        call.status,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duration: ${_formatDuration(call.duration)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(call.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatDuration(call.billableDuration),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(height: 0),
    );
  }
}

extension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
