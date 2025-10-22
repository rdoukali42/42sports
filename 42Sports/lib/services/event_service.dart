import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/event_type.dart';
import 'user_service.dart';
import '../utils/constants.dart';

class EventService {
  static const String _eventsKey = 'events';
  static const String _userEventsKey = 'user_events';

  Future<List<Event>> getAllEvents() async {
    if (AppConstants.useBackend) {
      try {
        final backendUrl = await AppConstants.getBackendUrl();
        final response = await http.get(
          Uri.parse('$backendUrl/events'),
        );
        
        if (response.statusCode == 200) {
          final List<dynamic> decoded = jsonDecode(response.body);
          return decoded.map((e) => Event.fromJson(e)).toList();
        }
      } catch (e) {
        print('Error fetching events from backend: $e');
        // Fall back to local storage
      }
    }
    
    // Local storage fallback
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(eventsJson);
    return decoded.map((e) => Event.fromJson(e)).toList();
  }

  Future<List<Event>> getOpenEvents() async {
    final events = await getAllEvents();
    return events
        .where((e) => e.status == EventStatus.open && e.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<Event>> getUserEvents(String userId) async {
    final events = await getAllEvents();
    return events.where((e) => e.participantIds.contains(userId)).toList();
  }

  Future<List<Event>> getUserCreatedEvents(String userId) async {
    final events = await getAllEvents();
    return events.where((e) => e.creatorId == userId).toList();
  }

  Future<List<Event>> getEventHistory(String userId) async {
    final events = await getAllEvents();
    return events
        .where((e) =>
            e.participantIds.contains(userId) &&
            (e.status == EventStatus.completed || e.status == EventStatus.cancelled))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<Event> createEvent(Event event) async {
    if (AppConstants.useBackend) {
      try {
        final backendUrl = await AppConstants.getBackendUrl();
        final response = await http.post(
          Uri.parse('$backendUrl/events'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(event.toJson()),
        );
        
        if (response.statusCode == 201) {
          return Event.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error creating event on backend: $e');
        // Fall back to local storage
      }
    }
    
    // Local storage fallback
    final events = await getAllEvents();
    events.add(event);
    await _saveEvents(events);
    return event;
  }

  Future<Event> updateEvent(Event updatedEvent) async {
    if (AppConstants.useBackend) {
      try {
        final backendUrl = await AppConstants.getBackendUrl();
        final response = await http.put(
          Uri.parse('$backendUrl/events/${updatedEvent.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedEvent.toJson()),
        );
        
        if (response.statusCode == 200) {
          return Event.fromJson(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error updating event on backend: $e');
        // Fall back to local storage
      }
    }
    
    // Local storage fallback
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == updatedEvent.id);
    
    if (index == -1) throw Exception('Event not found');
    
    events[index] = updatedEvent;
    await _saveEvents(events);
    return updatedEvent;
  }

  Future<Event> joinEvent(String eventId, String userId) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    
    if (index == -1) throw Exception('Event not found');
    
    final event = events[index];
    if (!event.canAcceptParticipants) {
      throw Exception('Event cannot accept more participants');
    }
    
    if (event.participantIds.contains(userId)) {
      throw Exception('Already joined this event');
    }

    final updatedParticipants = [...event.participantIds, userId];
    final updatedEvent = Event(
      id: event.id,
      name: event.name,
      description: event.description,
      date: event.date,
      location: event.location,
      minParticipants: event.minParticipants,
      maxParticipants: event.maxParticipants,
      type: event.type,
      logoUrl: event.logoUrl,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
      participantIds: updatedParticipants,
      status: event.maxParticipants != null && 
              updatedParticipants.length >= event.maxParticipants!
          ? EventStatus.full
          : EventStatus.open,
      createdAt: event.createdAt,
    );

    events[index] = updatedEvent;
    await _saveEvents(events);
    return updatedEvent;
  }

  Future<Event> leaveEvent(String eventId, String userId) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    
    if (index == -1) throw Exception('Event not found');
    
    final event = events[index];
    if (!event.participantIds.contains(userId)) {
      throw Exception('You are not part of this event');
    }

    if (event.creatorId == userId) {
      throw Exception('Event creator cannot leave. Please cancel the event instead.');
    }

    final updatedParticipants = event.participantIds.where((id) => id != userId).toList();
    final updatedEvent = Event(
      id: event.id,
      name: event.name,
      description: event.description,
      date: event.date,
      location: event.location,
      minParticipants: event.minParticipants,
      maxParticipants: event.maxParticipants,
      type: event.type,
      logoUrl: event.logoUrl,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
      participantIds: updatedParticipants,
      status: EventStatus.open,
      createdAt: event.createdAt,
    );

    events[index] = updatedEvent;
    await _saveEvents(events);
    return updatedEvent;
  }

  Future<void> cancelEvent(String eventId) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    
    if (index == -1) return;
    
    final event = events[index];
    
    // Refund 1 token to the creator
    final userService = UserService();
    final user = await userService.getUser();
    if (user != null && user.id == event.creatorId) {
      final newTokenCount = (user.tokens + AppConstants.eventTokenCost)
          .clamp(AppConstants.minTokens, AppConstants.maxTokens);
      final updatedUser = user.copyWith(tokens: newTokenCount);
      await userService.saveUser(updatedUser);
      print('Refunded ${AppConstants.eventTokenCost} token to ${user.login}. New balance: $newTokenCount');
    }
    
    final updatedEvent = Event(
      id: event.id,
      name: event.name,
      description: event.description,
      date: event.date,
      location: event.location,
      minParticipants: event.minParticipants,
      maxParticipants: event.maxParticipants,
      type: event.type,
      logoUrl: event.logoUrl,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
      participantIds: event.participantIds,
      status: EventStatus.cancelled,
      createdAt: event.createdAt,
    );

    await updateEvent(updatedEvent);
  }

  Future<void> completeEvent(String eventId) async {
    final events = await getAllEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    
    if (index == -1) return;
    
    final event = events[index];
    final updatedEvent = Event(
      id: event.id,
      name: event.name,
      description: event.description,
      date: event.date,
      location: event.location,
      minParticipants: event.minParticipants,
      maxParticipants: event.maxParticipants,
      type: event.type,
      logoUrl: event.logoUrl,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
      participantIds: event.participantIds,
      status: EventStatus.completed,
      createdAt: event.createdAt,
    );

    await updateEvent(updatedEvent);
  }

  Future<void> _saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_eventsKey, encoded);
  }
}
