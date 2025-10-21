import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../services/tournament_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class CreateTeamScreen extends StatefulWidget {
  final Tournament tournament;

  const CreateTeamScreen({super.key, required this.tournament});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final TournamentService _tournamentService = TournamentService();
  
  bool _isLoading = false;
  bool _showExistingTeams = true;
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }
  
  Future<void> _loadTeams() async {
    final teams = await _tournamentService.getTournamentTeams(widget.tournament.id);
    setState(() {
      _teams = teams;
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is already in a team
      for (final team in _teams) {
        if (team.isMember(user.id)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are already in team "${team.name}"'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final team = Team(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _teamNameController.text,
        tournamentId: widget.tournament.id,
        captainId: user.id,
        captainName: user.login,
        memberIds: [],
        memberNames: [],
        createdAt: DateTime.now(),
      );

      await _tournamentService.registerTeam(widget.tournament.id, team);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating team: $e'),
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

  Future<void> _joinTeam(Team team) async {
    // Check if team is full
    if (team.members.length >= widget.tournament.maxTeamSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This team is full'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Team'),
        content: Text('Do you want to join team "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is already in a team
      for (final existingTeam in _teams) {
        if (existingTeam.isMember(user.id)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are already in team "${existingTeam.name}"'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final member = TeamMember(
        userId: user.id,
        userName: user.login,
        joinedAt: DateTime.now(),
      );

      await _tournamentService.joinTeam(
        widget.tournament.id,
        team.id,
        member,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joined team successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining team: $e'),
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
    final availableTeams = _teams
        .where((team) => team.members.length < widget.tournament.maxTeamSize)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create or Join Team'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Card(
                    color: AppTheme.fortytwoBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.fortytwoCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Team Requirements',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Team size: ${widget.tournament.minTeamSize}-${widget.tournament.maxTeamSize} members',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '• You can create a new team or join an existing one',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            '• Each user can only be in one team per tournament',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle between create and join
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Create Team'),
                        icon: Icon(Icons.add),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Join Team'),
                        icon: Icon(Icons.group_add),
                      ),
                    ],
                    selected: {_showExistingTeams},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _showExistingTeams = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  if (!_showExistingTeams) ...[
                    // Create team form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _teamNameController,
                            decoration: const InputDecoration(
                              labelText: 'Team Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.groups),
                              hintText: 'Enter your team name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a team name';
                              }
                              if (value.length < 3) {
                                return 'Team name must be at least 3 characters';
                              }
                              // Check if team name already exists
                              if (_teams
                                  .any((team) => team.name == value)) {
                                return 'Team name already taken';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.blue.shade50,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You will be the team captain. Other players can join your team later.',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _createTeam,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Team'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Join existing team
                    if (availableTeams.isEmpty)
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
                                  'No teams available',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a new team to get started!',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Teams (${availableTeams.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ...availableTeams.map((team) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.fortytwoCyan
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.groups,
                                      color: AppTheme.fortytwoCyan,
                                    ),
                                  ),
                                  title: Text(
                                    team.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Captain: ${team.captainName}'),
                                      Text(
                                        '${team.members.length}/${widget.tournament.maxTeamSize} members',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => _joinTeam(team),
                                    child: const Text('Join'),
                                  ),
                                ),
                              )),
                        ],
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
