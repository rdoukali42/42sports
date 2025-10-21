import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/user_service.dart';
import '../widgets/event_card.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _eventService = EventService();
  final _userService = UserService();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final user = await _userService.getUser();
    if (user != null) {
      final events = await _eventService.getEventHistory(user.id);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<Event> get _completedEvents =>
      _events.where((e) => e.status == EventStatus.completed).toList();

  List<Event> get _cancelledEvents =>
      _events.where((e) => e.status == EventStatus.cancelled).toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: AppTheme.pureWhite,
          foregroundColor: AppTheme.deepBlack,
          bottom: TabBar(
            indicatorColor: AppTheme.neonGreen,
            labelColor: AppTheme.deepBlack,
            unselectedLabelColor: AppTheme.mediumGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Attended'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.neonGreen),
              )
            : TabBarView(
                children: [
                  _buildEventList(
                    _completedEvents,
                    'No attended events',
                    Icons.emoji_events,
                  ),
                  _buildEventList(
                    _cancelledEvents,
                    'No cancelled events',
                    Icons.cancel_outlined,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEventList(List<Event> events, String emptyMessage, IconData icon) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepBlack,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppTheme.neonGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: events[index],
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
