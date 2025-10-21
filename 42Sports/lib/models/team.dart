class TeamMember {
  final String userId;
  final String userName;
  final DateTime joinedAt;

  TeamMember({
    required this.userId,
    required this.userName,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['user_id'],
      userName: json['user_name'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}

class Team {
  final String id;
  final String name;
  final String tournamentId;
  final String captainId;
  final String captainName;
  final List<String> memberIds;
  final List<String> memberNames;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.tournamentId,
    required this.captainId,
    required this.captainName,
    List<String>? memberIds,
    List<String>? memberNames,
    DateTime? createdAt,
  })  : memberIds = memberIds ?? [],
        memberNames = memberNames ?? [],
        createdAt = createdAt ?? DateTime.now();
  
  // Helper to get members as TeamMember objects
  List<TeamMember> get members {
    List<TeamMember> result = [];
    // Add captain first
    result.add(TeamMember(
      userId: captainId,
      userName: captainName,
      joinedAt: createdAt,
    ));
    // Add other members
    for (int i = 0; i < memberIds.length; i++) {
      result.add(TeamMember(
        userId: memberIds[i],
        userName: i < memberNames.length ? memberNames[i] : 'Unknown',
        joinedAt: createdAt,
      ));
    }
    return result;
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'].toString(),
      name: json['name'],
      tournamentId: json['tournament_id'],
      captainId: json['captain_id'],
      captainName: json['captain_name'],
      memberIds: List<String>.from(json['member_ids'] ?? []),
      memberNames: List<String>.from(json['member_names'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tournament_id': tournamentId,
      'captain_id': captainId,
      'captain_name': captainName,
      'member_ids': memberIds,
      'member_names': memberNames,
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get totalMembers => memberIds.length + 1; // +1 for captain
  
  bool isMember(String userId) =>
      captainId == userId || memberIds.contains(userId);
}
