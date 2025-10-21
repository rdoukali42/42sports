import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../services/tournament_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/theme.dart';
import '../widgets/bracket_view.dart';
import 'create_team_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late Tournament _tournament;
  final TournamentService _tournamentService = TournamentService();
  bool _isLoading = false;
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _loadTournament();
  }

  Future<void> _loadTournament() async {
    try {
      final tournament = await _tournamentService.getTournamentById(_tournament.id);
      final teams = await _tournamentService.getTournamentTeams(_tournament.id);
      if (tournament != null && mounted) {
        setState(() {
          _tournament = tournament;
          _teams = teams;
        });
      }
    } catch (e) {
      debugPrint('Error loading tournament: $e');
    }
  }

  Future<bool> _isOrganizer() async {
    final user = await UserService().getUser();
    return user?.id == _tournament.creatorId;
  }

  Future<Team?> _getUserTeam() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return null;

    for (final team in _teams) {
      if (team.isMember(user.id)) {
        return team;
      }
    }
    return null;
  }

  Future<void> _startTournament() async {
    if (_tournament.teams.length < _tournament.minTeams) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need at least ${_tournament.minTeams} teams to start',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Tournament'),
        content: Text(
          'Are you sure you want to start the tournament with ${_tournament.teams.length} teams?\n\nThis will generate the bracket and no more teams can join.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _tournamentService.startTournament(_tournament.id);
      await _loadTournament();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament started! Bracket generated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting tournament: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelTournament() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Tournament'),
        content: const Text(
          'Are you sure you want to cancel this tournament?\n\nYou will get your 3 tokens back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Tournament'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _tournamentService.cancelTournament(_tournament.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament cancelled (3 tokens refunded)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling tournament: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_tournament.title),
        actions: [
          FutureBuilder<bool>(
            future: _isOrganizer(),
            builder: (context, snapshot) {
              if (snapshot.data == true &&
                  _tournament.status == TournamentStatus.registering) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'start') {
                      _startTournament();
                    } else if (value == 'cancel') {
                      _cancelTournament();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'start',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text('Start Tournament'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancel Tournament'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTournament,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status banner
                    _buildStatusBanner(),
                    const SizedBox(height: 16),

                    // Tournament info card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _tournament.sport?.icon ?? Icons.sports,
                                  size: 32,
                                  color: AppTheme.fortytwoCyan,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tournament.sport?.displayName ?? 'Tournament',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        dateFormat.format(_tournament.dateTime),
                                        style:
                                            Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _tournament.matchmakingType ==
                                            MatchmakingType.auto
                                        ? Colors.purple.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _tournament.matchmakingType ==
                                            MatchmakingType.auto
                                        ? 'Auto Matchmaking'
                                        : 'Manual Matchmaking',
                                    style: TextStyle(
                                      color: _tournament.matchmakingType ==
                                              MatchmakingType.auto
                                          ? Colors.purple
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _tournament.location,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _tournament.description ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildInfoBox(
                                  'Teams',
                                  '${_tournament.teams.length}/${_tournament.maxTeams}',
                                  Icons.groups,
                                ),
                                const SizedBox(width: 12),
                                _buildInfoBox(
                                  'Team Size',
                                  '${_tournament.minTeamSize}-${_tournament.maxTeamSize}',
                                  Icons.person,
                                ),
                                const SizedBox(width: 12),
                                _buildInfoBox(
                                  'Organizer',
                                  _tournament.organizerName,
                                  Icons.person_outline,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Teams section
                    Text(
                      'Teams (${_teams.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_teams.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.groups_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No teams yet',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._teams.map((team) => _buildTeamCard(team)),

                    const SizedBox(height: 16),

                    // Join/Create team button
                    if (_tournament.status == TournamentStatus.registering)
                      FutureBuilder<Team?>(
                        future: _getUserTeam(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final userTeam = snapshot.data;
                          if (userTeam != null) {
                            return Card(
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'You are in team "${userTeam.name}"',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (_tournament.teams.length >= (_tournament.maxTeams ?? 999)) {
                            return Card(
                              color: Colors.orange.shade50,
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.orange),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Tournament is full',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateTeamScreen(
                                    tournament: _tournament,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadTournament();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create/Join Team'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          );
                        },
                      ),

                    // Bracket view (if tournament started)
                    if (_tournament.status == TournamentStatus.ongoing ||
                        _tournament.status == TournamentStatus.completed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Tournament Bracket',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: BracketView(bracketData: _tournament.bracketData ?? ''),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    IconData icon;
    String text;

    switch (_tournament.status) {
      case TournamentStatus.registering:
        color = Colors.blue;
        icon = Icons.how_to_reg;
        text = 'Registration Open';
        break;
      case TournamentStatus.ready:
        color = Colors.orange;
        icon = Icons.sports_kabaddi;
        text = 'Ready to Start';
        break;
      case TournamentStatus.ongoing:
        color = Colors.purple;
        icon = Icons.sports_esports;
        text = 'Tournament in Progress';
        break;
      case TournamentStatus.completed:
        color = Colors.green;
        icon = Icons.emoji_events;
        text = 'Tournament Completed';
        break;
      case TournamentStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Tournament Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.fortytwoCyan),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.fortytwoCyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: AppTheme.fortytwoCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Captain: ${team.captainName}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${team.members.length} members',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (team.members.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: team.members
                    .where((m) => m.userId != team.captainId)
                    .map((member) => Chip(
                          label: Text(member.userName),
                          avatar: const Icon(Icons.person, size: 16),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
