import 'event_type.dart';

enum EventStatus { open, full, completed, cancelled }

class Event {
  final String id;
  final String name;
  final String? description;
  final DateTime date;
  final String location;
  final int minParticipants;
  final int? maxParticipants;
  final EventType type;
  final String? logoUrl;
  final String creatorId;
  final String creatorName;
  final List<String> participantIds;
  final EventStatus status;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    this.description,
    required this.date,
    required this.location,
    required this.minParticipants,
    this.maxParticipants,
    required this.type,
    this.logoUrl,
    required this.creatorId,
    required this.creatorName,
    List<String>? participantIds,
    this.status = EventStatus.open,
    DateTime? createdAt,
  })  : participantIds = participantIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      minParticipants: json['min_participants'],
      maxParticipants: json['max_participants'],
      type: EventType.values[json['type']],
      logoUrl: json['logo_url'],
      creatorId: json['creator_id'],
      creatorName: json['creator_name'],
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      status: EventStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'min_participants': minParticipants,
      'max_participants': maxParticipants,
      'type': type.index,
      'logo_url': logoUrl,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'participant_ids': participantIds,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isFull =>
      maxParticipants != null && participantIds.length >= maxParticipants!;

  bool get canAcceptParticipants =>
      status == EventStatus.open && !isFull && date.isAfter(DateTime.now());

  int get currentParticipants => participantIds.length;

  String get participantsText {
    if (maxParticipants != null) {
      return '$currentParticipants / $maxParticipants';
    }
    return '$currentParticipants participants';
  }
}
