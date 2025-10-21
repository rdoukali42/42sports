import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../utils/theme.dart';
import '../widgets/tournament_card.dart';
import 'tournament_detail_screen.dart';
import 'create_tournament_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final TournamentService _tournamentService = TournamentService();
  List<Tournament> _tournaments = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, registration, inProgress, completed

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tournaments = await _tournamentService.getAllTournaments();
      if (mounted) {
        setState(() {
          _tournaments = tournaments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tournaments: $e')),
        );
      }
    }
  }

  List<Tournament> _getFilteredTournaments() {
    switch (_filter) {
      case 'registration':
        return _tournaments
            .where((t) => t.status == TournamentStatus.registering)
            .toList();
      case 'inProgress':
        return _tournaments
            .where((t) =>
                t.status == TournamentStatus.ready ||
                t.status == TournamentStatus.ongoing)
            .toList();
      case 'completed':
        return _tournaments
            .where((t) =>
                t.status == TournamentStatus.completed ||
                t.status == TournamentStatus.cancelled)
            .toList();
      default:
        return _tournaments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTournaments = _getFilteredTournaments();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Tournaments'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.deepBlack,
        actions: [
          // Create Tournament Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTournamentScreen(),
                  ),
                );
                if (result == true) {
                  _loadTournaments();
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.deepBlack,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12), // Add spacing from top
          // Filter chips
          Container(
            color: AppTheme.pureWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _tournaments.length),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Registration',
                    'registration',
                    _tournaments
                        .where((t) => t.status == TournamentStatus.registering)
                        .length,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Active',
                    'inProgress',
                    _tournaments
                        .where((t) =>
                            t.status == TournamentStatus.ready ||
                            t.status == TournamentStatus.ongoing)
                        .length,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    'Completed',
                    'completed',
                    _tournaments
                        .where((t) =>
                            t.status == TournamentStatus.completed ||
                            t.status == TournamentStatus.cancelled)
                        .length,
                  ),
                ],
              ),
            ),
          ),

          // Tournament list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.neonGreen),
                  )
                : filteredTournaments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.neonGreen.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No tournaments found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create one to get started!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTournaments,
                        color: AppTheme.neonGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredTournaments.length,
                          itemBuilder: (context, index) {
                            final tournament = filteredTournaments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TournamentCard(
                                tournament: tournament,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TournamentDetailScreen(tournament: tournament),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadTournaments();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.neonGreen : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.neonGreen : AppTheme.lightGray,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _filter = value;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.deepBlack : AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.deepBlack
                        : AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.neonGreen : AppTheme.mediumGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
