import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/user_service.dart';
import '../utils/theme.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventService = EventService();
  final _userService = UserService();
  bool _isLoading = false;
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _joinEvent() async {
    final user = await _userService.getUser();
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updated = await _eventService.joinEvent(_event.id, user.id);
      setState(() => _event = updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined event!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveEvent() async {
    final user = await _userService.getUser();
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Event'),
        content: const Text('Are you sure you want to leave this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final updated = await _eventService.leaveEvent(_event.id, user.id);
      setState(() => _event = updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the event')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelEvent() async {
    final user = await _userService.getUser();
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text(
          'Are you sure you want to cancel this event? '
          'You will get your token back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _eventService.cancelEvent(_event.id);
      await _userService.refundToken(user.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event cancelled. Token refunded.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          FutureBuilder<bool>(
            future: _isCreator(),
            builder: (context, snapshot) {
              if (snapshot.data == true && _event.status == EventStatus.open) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.push<Event>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEventScreen(event: _event),
                      ),
                    );
                    if (updated != null) {
                      setState(() => _event = updated);
                    }
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _event.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _event.isFull
                                ? AppTheme.error
                                : AppTheme.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _event.isFull ? 'FULL' : 'OPEN',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _event.type.displayName,
                      style: TextStyle(color: AppTheme.primary),
                    ),
                    const Divider(height: 24),
                    if (_event.description != null) ...[
                      Text(
                        _event.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('MMM dd, yyyy - HH:mm')
                          .format(_event.date),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: _event.location,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.people,
                      label: 'Participants',
                      value: _event.participantsText,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Organizer',
                      value: _event.creatorName,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserEventStatus(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final status = snapshot.data!;
                final hasJoined = status['hasJoined'] as bool;
                final isCreator = status['isCreator'] as bool;

                if (isCreator) {
                  // Show cancel button for event creator
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: AppTheme.primary.withOpacity(0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text('You created this event'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _cancelEvent,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                        ),
                      ),
                    ],
                  );
                }

                if (hasJoined) {
                  // Show leave button for participants
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: AppTheme.success.withOpacity(0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.success),
                              SizedBox(width: 8),
                              Text('You have joined this event'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _leaveEvent,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Leave Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                        ),
                      ),
                    ],
                  );
                }

                // Show join button for non-participants
                return ElevatedButton(
                  onPressed: _isLoading || !_event.canAcceptParticipants
                      ? null
                      : _joinEvent,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Join Event'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserEventStatus() async {
    final user = await _userService.getUser();
    if (user == null) {
      return {'hasJoined': false, 'isCreator': false};
    }
    return {
      'hasJoined': _event.participantIds.contains(user.id),
      'isCreator': _event.creatorId == user.id,
    };
  }

  Future<bool> _isCreator() async {
    final user = await _userService.getUser();
    if (user == null) return false;
    return _event.creatorId == user.id;
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
