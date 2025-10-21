import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              // Header with sport icon and status
              Row(
                children: [
                  // Sport icon in neon green circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      event.type.icon,
                      color: AppTheme.neonGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.type.displayName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 20),
              
              // Creator name
              if (event.creatorName != null && event.creatorName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: AppTheme.mediumGray),
                      const SizedBox(width: 8),
                      Text(
                        'Created by ${event.creatorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.mediumGray,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              
              // Event details with modern icons
              _buildDetailRow(Icons.calendar_today_outlined, 
                DateFormat('MMM dd, yyyy • HH:mm').format(event.date)),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.location_on_outlined, event.location),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.group_outlined, event.participantsText),
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

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (event.status) {
      case EventStatus.open:
        if (event.isFull) {
          backgroundColor = AppTheme.error.withOpacity(0.15);
          textColor = AppTheme.error;
          text = 'FULL';
        } else {
          backgroundColor = AppTheme.neonGreen.withOpacity(0.15);
          textColor = AppTheme.neonGreen;
          text = 'OPEN';
        }
        break;
      case EventStatus.full:
        backgroundColor = AppTheme.error.withOpacity(0.15);
        textColor = AppTheme.error;
        text = 'FULL';
        break;
      case EventStatus.completed:
        backgroundColor = AppTheme.deepBlack.withOpacity(0.08);
        textColor = AppTheme.deepBlack;
        text = 'DONE';
        break;
      case EventStatus.cancelled:
        backgroundColor = AppTheme.mediumGray.withOpacity(0.15);
        textColor = AppTheme.mediumGray;
        text = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
