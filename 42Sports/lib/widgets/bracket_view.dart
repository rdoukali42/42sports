import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BracketView extends StatelessWidget {
  final String bracketData;

  const BracketView({super.key, required this.bracketData});

  @override
  Widget build(BuildContext context) {
    if (bracketData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Bracket not yet generated'),
          ),
        ),
      );
    }

    try {
      final bracket = json.decode(bracketData) as Map<String, dynamic>;
      final matches = (bracket['matches'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      if (matches.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No matches in bracket'),
            ),
          ),
        );
      }

      // Group matches by round
      final Map<int, List<Map<String, dynamic>>> matchesByRound = {};
      for (final match in matches) {
        final round = match['round'] as int;
        matchesByRound.putIfAbsent(round, () => []);
        matchesByRound[round]!.add(match);
      }

      final rounds = matchesByRound.keys.toList()..sort();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rounds.map((roundNum) {
              final roundMatches = matchesByRound[roundNum]!;
              return _buildRound(context, roundNum, roundMatches, rounds.length);
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error loading bracket: $e'),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRound(
    BuildContext context,
    int roundNum,
    List<Map<String, dynamic>> matches,
    int totalRounds,
  ) {
    String roundName;
    if (roundNum == totalRounds) {
      roundName = 'Final';
    } else if (roundNum == totalRounds - 1) {
      roundName = 'Semi-Finals';
    } else if (roundNum == totalRounds - 2) {
      roundName = 'Quarter-Finals';
    } else {
      roundName = 'Round $roundNum';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Round header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.fortytwoCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roundName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Matches in this round
          Column(
            children: matches.asMap().entries.map((entry) {
              final index = entry.key;
              final match = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < matches.length - 1 ? 24 : 0,
                ),
                child: _buildMatchCard(context, match),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    final matchId = match['id'] as int;
    final team1 = match['team1'] as String?;
    final team2 = match['team2'] as String?;
    final winner = match['winner'] as String?;
    final isBye = match['bye'] as bool? ?? false;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Match header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Text(
              'Match $matchId',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          
          // Team 1
          _buildTeamSlot(
            context,
            team1 ?? 'TBD',
            isWinner: winner == team1,
            isTBD: team1 == null,
            isBye: isBye && team2 == null,
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          
          // Team 2
          _buildTeamSlot(
            context,
            team2 ?? (isBye ? 'BYE' : 'TBD'),
            isWinner: winner == team2,
            isTBD: team2 == null && !isBye,
            isBye: isBye,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSlot(
    BuildContext context,
    String teamName, {
    bool isWinner = false,
    bool isTBD = false,
    bool isBye = false,
  }) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;

    if (isWinner) {
      backgroundColor = AppTheme.fortytwoCyan.withOpacity(0.2);
      textColor = AppTheme.fortytwoCyan;
      fontWeight = FontWeight.bold;
    } else if (isTBD) {
      textColor = Colors.grey.shade400;
    } else if (isBye) {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade500;
      fontWeight = FontWeight.w300;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.emoji_events,
                size: 16,
                color: AppTheme.fortytwoCyan,
              ),
            ),
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
