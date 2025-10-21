import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/event_type.dart';
import '../services/tournament_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  EventType _selectedSport = EventType.football;
  MatchmakingType _matchmakingType = MatchmakingType.auto;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  
  int _minTeams = 4;
  int _maxTeams = 8;
  int _minTeamSize = 2;
  int _maxTeamSize = 5;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate team constraints
    if (_minTeams < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum teams must be at least 2')),
      );
      return;
    }

    if (_maxTeams < _minTeams) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum teams must be greater than minimum teams')),
      );
      return;
    }

    if (_minTeamSize < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum team size must be at least 1')),
      );
      return;
    }

    if (_maxTeamSize < _minTeamSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum team size must be greater than minimum team size')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user from local storage (which has the updated token count)
      final user = await UserService().getUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Creating tournament - User: ${user.login}, Tokens: ${user.tokens}');

      // Check if user has enough tokens
      if (user.tokens < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need 3 tokens to create a tournament (you have ${user.tokens})'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final tournament = Tournament(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _titleController.text,
        description: _descriptionController.text,
        startDate: dateTime,
        location: _locationController.text,
        creatorId: user.id,
        creatorName: user.login,
        minTeams: _minTeams,
        maxTeams: _maxTeams,
        minTeamSize: _minTeamSize,
        maxTeamSize: _maxTeamSize,
        matchmakingType: _matchmakingType,
        teamIds: [],
        status: TournamentStatus.registering,
        createdAt: DateTime.now(),
        bracketData: '',
        sport: _selectedSport,
      );

      await TournamentService().createTournament(tournament);

      // Deduct 3 tokens from user
      final newTokenCount = (user.tokens - AppConstants.tournamentTokenCost)
          .clamp(AppConstants.minTokens, AppConstants.maxTokens)
          .toInt();
      final updatedUser = user.copyWith(tokens: newTokenCount);
      await UserService().saveUser(updatedUser);
      print('Tournament created - Deducted ${AppConstants.tournamentTokenCost} tokens. New balance: $newTokenCount');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament created successfully! (3 tokens spent)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tournament: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.deepBlack,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cost indicator
                    Card(
                      color: AppTheme.fortytwoBlue,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars, color: AppTheme.fortytwoCyan),
                            const SizedBox(width: 8),
                            Text(
                              'Creating this tournament costs 3 tokens',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tournament Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emoji_events),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Sport Type
                    DropdownButtonFormField<EventType>(
                      value: _selectedSport,
                      decoration: const InputDecoration(
                        labelText: 'Sport',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sports),
                      ),
                      items: EventType.values.map((EventType type) {
                        return DropdownMenuItem<EventType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (EventType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSport = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Matchmaking Type
                    Text(
                      'Matchmaking Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<MatchmakingType>(
                      segments: const [
                        ButtonSegment(
                          value: MatchmakingType.auto,
                          label: Text('Auto'),
                          icon: Icon(Icons.auto_fix_high),
                        ),
                        ButtonSegment(
                          value: MatchmakingType.manual,
                          label: Text('Manual'),
                          icon: Icon(Icons.person),
                        ),
                      ],
                      selected: {_matchmakingType},
                      onSelectionChanged: (Set<MatchmakingType> newSelection) {
                        setState(() {
                          _matchmakingType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _matchmakingType == MatchmakingType.auto
                          ? 'Teams will be automatically matched in brackets'
                          : 'Organizer will manually arrange matchups',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    
                    // Team Configuration
                    Text(
                      'Team Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Min/Max Teams
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Min Teams: $_minTeams'),
                              Slider(
                                value: _minTeams.toDouble(),
                                min: 2,
                                max: 32,
                                divisions: 30,
                                label: _minTeams.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _minTeams = value.toInt();
                                    if (_maxTeams < _minTeams) {
                                      _maxTeams = _minTeams;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Teams: $_maxTeams'),
                              Slider(
                                value: _maxTeams.toDouble(),
                                min: 2,
                                max: 32,
                                divisions: 30,
                                label: _maxTeams.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _maxTeams = value.toInt();
                                    if (_minTeams > _maxTeams) {
                                      _minTeams = _maxTeams;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Min/Max Team Size
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Min Team Size: $_minTeamSize'),
                              Slider(
                                value: _minTeamSize.toDouble(),
                                min: 1,
                                max: 20,
                                divisions: 19,
                                label: _minTeamSize.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _minTeamSize = value.toInt();
                                    if (_maxTeamSize < _minTeamSize) {
                                      _maxTeamSize = _minTeamSize;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Max Team Size: $_maxTeamSize'),
                              Slider(
                                value: _maxTeamSize.toDouble(),
                                min: 1,
                                max: 20,
                                divisions: 19,
                                label: _maxTeamSize.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _maxTeamSize = value.toInt();
                                    if (_minTeamSize > _maxTeamSize) {
                                      _minTeamSize = _maxTeamSize;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Create Button
                    ElevatedButton.icon(
                      onPressed: _createTournament,
                      icon: const Icon(Icons.emoji_events, color: AppTheme.deepBlack),
                      label: const Text('Create Tournament', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        foregroundColor: AppTheme.deepBlack,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32), // Extra padding at bottom
                  ],
                ),
              ),
            ),
    );
  }
}
