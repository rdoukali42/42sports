import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournament.dart';
import '../utils/theme.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepBlack.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title, sport icon and matchmaking type
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tournament.sport?.icon ?? Icons.emoji_events,
                      color: AppTheme.neonGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tournament.sport?.displayName ?? 'Tournament',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Matchmaking type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: tournament.matchmakingType == MatchmakingType.auto
                          ? AppTheme.neonGreen.withOpacity(0.15)
                          : AppTheme.deepBlack.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tournament.matchmakingType == MatchmakingType.auto
                              ? Icons.auto_fix_high
                              : Icons.person,
                          size: 14,
                          color: tournament.matchmakingType == MatchmakingType.auto
                              ? AppTheme.neonGreen
                              : AppTheme.deepBlack,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tournament.matchmakingType == MatchmakingType.auto
                              ? 'Auto'
                              : 'Manual',
                          style: TextStyle(
                            fontSize: 11,
                            color: tournament.matchmakingType == MatchmakingType.auto
                                ? AppTheme.neonGreen
                                : AppTheme.deepBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              if (tournament.description != null && tournament.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    tournament.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.deepBlack,
                        ),
                  ),
                ),

              // Creator name
              if (tournament.creatorName != null && tournament.creatorName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: AppTheme.mediumGray),
                      const SizedBox(width: 8),
                      Text(
                        'Created by ${tournament.creatorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGray,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),

              // Location and Date
              _buildDetailRow(Icons.location_on_outlined, tournament.location),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.calendar_today_outlined, dateFormat.format(tournament.dateTime)),
              const SizedBox(height: 16),

              // Teams info and status row
              Row(
                children: [
                  // Teams count with neon green dot
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.neonGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tournament.teams.length}/${tournament.maxTeams ?? '∞'} teams',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepBlack,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  _buildStatusBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mediumGray),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.deepBlack,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (tournament.status) {
      case TournamentStatus.registering:
        backgroundColor = AppTheme.neonGreen.withOpacity(0.15);
        textColor = AppTheme.neonGreen;
        icon = Icons.how_to_reg;
        text = 'OPEN';
        break;
      case TournamentStatus.ready:
        backgroundColor = AppTheme.deepBlack.withOpacity(0.08);
        textColor = AppTheme.deepBlack;
        icon = Icons.sports_kabaddi;
        text = 'READY';
        break;
      case TournamentStatus.ongoing:
        backgroundColor = Color(0xFF9333EA).withOpacity(0.15);
        textColor = Color(0xFF9333EA);
        icon = Icons.sports_esports;
        text = 'LIVE';
        break;
      case TournamentStatus.completed:
        backgroundColor = AppTheme.deepBlack.withOpacity(0.08);
        textColor = AppTheme.deepBlack;
        icon = Icons.emoji_events;
        text = 'DONE';
        break;
      case TournamentStatus.cancelled:
        backgroundColor = AppTheme.mediumGray.withOpacity(0.15);
        textColor = AppTheme.mediumGray;
        icon = Icons.cancel;
        text = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
