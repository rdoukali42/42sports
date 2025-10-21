import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import 'user_service.dart';
import '../utils/constants.dart';

class TournamentService {
  static const String _tournamentsKey = 'tournaments';
  static const String _teamsKey = 'teams';

  Future<List<Tournament>> getAllTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final tournamentsJson = prefs.getString(_tournamentsKey);
    if (tournamentsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tournamentsJson);
    return decoded.map((e) => Tournament.fromJson(e)).toList();
  }

  Future<List<Tournament>> getOpenTournaments() async {
    final tournaments = await getAllTournaments();
    return tournaments
        .where((t) =>
            t.status == TournamentStatus.registering &&
            t.startDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Future<Tournament> createTournament(Tournament tournament) async {
    final tournaments = await getAllTournaments();
    tournaments.add(tournament);
    await _saveTournaments(tournaments);
    return tournament;
  }

  Future<Tournament> updateTournament(Tournament updated) async {
    final tournaments = await getAllTournaments();
    final index = tournaments.indexWhere((t) => t.id == updated.id);
    
    if (index == -1) throw Exception('Tournament not found');
    
    tournaments[index] = updated;
    await _saveTournaments(tournaments);
    return updated;
  }

  Future<void> cancelTournament(String tournamentId) async {
    final tournaments = await getAllTournaments();
    final index = tournaments.indexWhere((t) => t.id == tournamentId);
    
    if (index == -1) return;
    
    final tournament = tournaments[index];
    
    // Refund 3 tokens to the creator
    final userService = UserService();
    final user = await userService.getUser();
    if (user != null && user.id == tournament.creatorId) {
      final newTokenCount = (user.tokens + AppConstants.tournamentTokenCost)
          .clamp(AppConstants.minTokens, AppConstants.maxTokens);
      final updatedUser = user.copyWith(tokens: newTokenCount);
      await userService.saveUser(updatedUser);
      print('Refunded ${AppConstants.tournamentTokenCost} tokens to ${user.login}. New balance: $newTokenCount');
    }
    
    tournaments[index] = Tournament(
      id: tournament.id,
      name: tournament.name,
      description: tournament.description,
      startDate: tournament.startDate,
      location: tournament.location,
      minTeams: tournament.minTeams,
      maxTeams: tournament.maxTeams,
      minTeamSize: tournament.minTeamSize,
      maxTeamSize: tournament.maxTeamSize,
      matchmakingType: tournament.matchmakingType,
      rules: tournament.rules,
      creatorId: tournament.creatorId,
      creatorName: tournament.creatorName,
      teamIds: tournament.teamIds,
      status: TournamentStatus.cancelled,
      createdAt: tournament.createdAt,
      bracketData: tournament.bracketData,
    );

    await _saveTournaments(tournaments);
  }

  // Team Management
  Future<List<Team>> getAllTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = prefs.getString(_teamsKey);
    if (teamsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(teamsJson);
    return decoded.map((e) => Team.fromJson(e)).toList();
  }

  Future<List<Team>> getTournamentTeams(String tournamentId) async {
    final teams = await getAllTeams();
    return teams.where((t) => t.tournamentId == tournamentId).toList();
  }

  Future<Team> createTeam(Team team) async {
    final teams = await getAllTeams();
    teams.add(team);
    await _saveTeams(teams);

    // Update tournament with new team ID
    final tournaments = await getAllTournaments();
    final tIndex = tournaments.indexWhere((t) => t.id == team.tournamentId);
    if (tIndex != -1) {
      final tournament = tournaments[tIndex];
      final updatedTeamIds = [...tournament.teamIds, team.id];
      tournaments[tIndex] = Tournament(
        id: tournament.id,
        name: tournament.name,
        description: tournament.description,
        startDate: tournament.startDate,
        location: tournament.location,
        minTeams: tournament.minTeams,
        maxTeams: tournament.maxTeams,
        minTeamSize: tournament.minTeamSize,
        maxTeamSize: tournament.maxTeamSize,
        matchmakingType: tournament.matchmakingType,
        rules: tournament.rules,
        creatorId: tournament.creatorId,
        creatorName: tournament.creatorName,
        teamIds: updatedTeamIds,
        status: tournament.maxTeams != null &&
                updatedTeamIds.length >= tournament.maxTeams!
            ? TournamentStatus.ready
            : (updatedTeamIds.length >= tournament.minTeams
                ? TournamentStatus.ready
                : TournamentStatus.registering),
        createdAt: tournament.createdAt,
        bracketData: tournament.bracketData,
      );
      await _saveTournaments(tournaments);
    }

    return team;
  }

  Future<Team?> updateTeam(Team updated) async {
    final teams = await getAllTeams();
    final index = teams.indexWhere((t) => t.id == updated.id);
    
    if (index == -1) return null;
    
    teams[index] = updated;
    await _saveTeams(teams);
    return updated;
  }

  Future<void> registerTeam(String tournamentId, Team team) async {
    await createTeam(team);
  }

  Future<void> joinTeam(String tournamentId, String teamId, TeamMember member) async {
    final teams = await getAllTeams();
    final index = teams.indexWhere((t) => t.id == teamId);
    
    if (index == -1) throw Exception('Team not found');
    
    final team = teams[index];
    final updatedMemberIds = [...team.memberIds, member.userId];
    final updatedMemberNames = [...team.memberNames, member.userName];
    
    teams[index] = Team(
      id: team.id,
      name: team.name,
      tournamentId: team.tournamentId,
      captainId: team.captainId,
      captainName: team.captainName,
      memberIds: updatedMemberIds,
      memberNames: updatedMemberNames,
      createdAt: team.createdAt,
    );
    
    await _saveTeams(teams);
  }

  Future<Tournament?> getTournamentById(String id) async {
    final tournaments = await getAllTournaments();
    try {
      return tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> startTournament(String tournamentId) async {
    final tournament = await getTournamentById(tournamentId);
    if (tournament == null) throw Exception('Tournament not found');
    
    if (tournament.teamIds.length < tournament.minTeams) {
      throw Exception('Not enough teams to start tournament');
    }

    // Generate bracket
    final bracketData = await generateBracket(tournamentId);
    final bracketJson = jsonEncode(bracketData);

    // Update tournament status
    final tournaments = await getAllTournaments();
    final index = tournaments.indexWhere((t) => t.id == tournamentId);
    
    tournaments[index] = Tournament(
      id: tournament.id,
      name: tournament.name,
      description: tournament.description,
      startDate: tournament.startDate,
      location: tournament.location,
      minTeams: tournament.minTeams,
      maxTeams: tournament.maxTeams,
      minTeamSize: tournament.minTeamSize,
      maxTeamSize: tournament.maxTeamSize,
      matchmakingType: tournament.matchmakingType,
      rules: tournament.rules,
      creatorId: tournament.creatorId,
      creatorName: tournament.creatorName,
      teamIds: tournament.teamIds,
      status: TournamentStatus.ongoing,
      createdAt: tournament.createdAt,
      bracketData: bracketJson,
      sport: tournament.sport,
    );

    await _saveTournaments(tournaments);
  }

  // Auto Matchmaking Algorithm
  Future<Map<String, dynamic>> generateBracket(String tournamentId) async {
    final teams = await getTournamentTeams(tournamentId);
    final numTeams = teams.length;
    
    if (numTeams < 2) {
      throw Exception('Need at least 2 teams for bracket generation');
    }

    // Shuffle teams for fairness
    final shuffledTeams = List<Team>.from(teams)..shuffle(Random());
    
    // Generate bracket structure
    final bracket = _createFlexibleBracket(shuffledTeams);
    
    return bracket;
  }

  Map<String, dynamic> _createFlexibleBracket(List<Team> teams) {
    final numTeams = teams.length;
    
    // Calculate number of rounds needed
    final numRounds = (log(numTeams) / log(2)).ceil();
    final nextPowerOf2 = pow(2, numRounds).toInt();
    final byes = nextPowerOf2 - numTeams;

    List<Map<String, dynamic>> matches = [];
    
    // First round matchups
    int matchId = 1;
    int teamIndex = 0;
    
    for (int i = 0; i < nextPowerOf2 / 2; i++) {
      if (byes > 0 && i < byes) {
        // Give bye to team
        matches.add({
          'id': matchId++,
          'round': 1,
          'team1_id': teams[teamIndex].id,
          'team1_name': teams[teamIndex].name,
          'team2_id': null,
          'team2_name': 'BYE',
          'winner_id': teams[teamIndex].id, // Auto-advance
          'status': 'completed',
        });
        teamIndex++;
      } else {
        // Regular match
        if (teamIndex < numTeams && teamIndex + 1 < numTeams) {
          matches.add({
            'id': matchId++,
            'round': 1,
            'team1_id': teams[teamIndex].id,
            'team1_name': teams[teamIndex].name,
            'team2_id': teams[teamIndex + 1].id,
            'team2_name': teams[teamIndex + 1].name,
            'winner_id': null,
            'status': 'pending',
          });
          teamIndex += 2;
        }
      }
    }

    return {
      'total_rounds': numRounds,
      'total_teams': numTeams,
      'matches': matches,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _saveTournaments(List<Tournament> tournaments) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tournaments.map((t) => t.toJson()).toList());
    await prefs.setString(_tournamentsKey, encoded);
  }

  Future<void> _saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(teams.map((t) => t.toJson()).toList());
    await prefs.setString(_teamsKey, encoded);
  }
}
