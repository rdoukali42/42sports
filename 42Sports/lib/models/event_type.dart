import 'package:flutter/material.dart';

enum EventType {
  futsal,
  football,
  volleyball,
  handball,
  basketball,
  videoGame,
  monasGames;

  String get displayName {
    switch (this) {
      case EventType.futsal:
        return 'Futsal';
      case EventType.football:
        return 'Football (11 vs 11)';
      case EventType.volleyball:
        return 'Volleyball';
      case EventType.handball:
        return 'Handball';
      case EventType.basketball:
        return 'Basketball';
      case EventType.videoGame:
        return 'Video Game';
      case EventType.monasGames:
        return 'Mona\'s Games';
    }
  }
  
  IconData get icon {
    switch (this) {
      case EventType.futsal:
        return Icons.sports_soccer;
      case EventType.football:
        return Icons.sports_football;
      case EventType.volleyball:
        return Icons.sports_volleyball;
      case EventType.handball:
        return Icons.sports_handball;
      case EventType.basketball:
        return Icons.sports_basketball;
      case EventType.videoGame:
        return Icons.sports_esports;
      case EventType.monasGames:
        return Icons.sports;
    }
  }
}
