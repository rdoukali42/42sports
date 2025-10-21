import 'event_type.dart';

enum MatchmakingType { manual, auto }

enum TournamentStatus { 
  registering, // Accepting teams (alias: registration)
  ready,       // Min teams reached, ready to start
  ongoing,     // Tournament in progress (alias: inProgress)
  completed,   // Finished
  cancelled    // Cancelled
}

// Aliases for backward compatibility
extension TournamentStatusExtension on TournamentStatus {
  static TournamentStatus get registration => TournamentStatus.registering;
  static TournamentStatus get inProgress => TournamentStatus.ongoing;
}

class Tournament {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final String location;
  final int minTeams;
  final int? maxTeams;
  final int minTeamSize;
  final int maxTeamSize;
  final MatchmakingType matchmakingType;
  final String? rules;
  final String creatorId;
  final String creatorName;
  final List<String> teamIds;
  final TournamentStatus status;
  final DateTime createdAt;
  final String? bracketData; // JSON string for bracket information
  final EventType? sport; // Sport type

  Tournament({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.location,
    required this.minTeams,
    this.maxTeams,
    required this.minTeamSize,
    required this.maxTeamSize,
    required this.matchmakingType,
    this.rules,
    required this.creatorId,
    required this.creatorName,
    List<String>? teamIds,
    this.status = TournamentStatus.registering,
    DateTime? createdAt,
    this.bracketData,
    this.sport,
  })  : teamIds = teamIds ?? [],
        createdAt = createdAt ?? DateTime.now();
  
  // Aliases for compatibility
  String get title => name;
  DateTime get dateTime => startDate;
  String get organizerId => creatorId;
  String get organizerName => creatorName;
  List<String> get teams => teamIds; // Returns list of team IDs

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      location: json['location'],
      minTeams: json['min_teams'],
      maxTeams: json['max_teams'],
      minTeamSize: json['min_team_size'],
      maxTeamSize: json['max_team_size'],
      matchmakingType: MatchmakingType.values[json['matchmaking_type']],
      rules: json['rules'],
      creatorId: json['creator_id'],
      creatorName: json['creator_name'],
      teamIds: List<String>.from(json['team_ids'] ?? []),
      status: TournamentStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']),
      bracketData: json['bracket_data'],
      sport: json['sport'] != null ? EventType.values[json['sport']] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'location': location,
      'min_teams': minTeams,
      'max_teams': maxTeams,
      'min_team_size': minTeamSize,
      'max_team_size': maxTeamSize,
      'matchmaking_type': matchmakingType.index,
      'rules': rules,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'team_ids': teamIds,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
      'bracket_data': bracketData,
      'sport': sport?.index,
    };
  }

  bool get isFull => maxTeams != null && teamIds.length >= maxTeams!;
  
  bool get canStart => teamIds.length >= minTeams;
  
  int get currentTeams => teamIds.length;
  
  String get teamsText {
    if (maxTeams != null) {
      return '$currentTeams / $maxTeams teams';
    }
    return '$currentTeams teams';
  }
}
