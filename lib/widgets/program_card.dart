import 'package:flutter/material.dart';

import '../models/program.dart';
import '../services/auth_repository.dart';

class ProgramCard extends StatelessWidget {
  final Program program;
  final VoidCallback? onTap;
  final bool showLocation;
  final bool showSeats;

  const ProgramCard({
    super.key,
    required this.program,
    this.onTap,
    this.showLocation = true,
    this.showSeats = true,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleLines = <String>[program.category];
    if (showLocation) subtitleLines.add(program.location);
    if (showSeats) subtitleLines.add('${program.seatsAvailable} seats left');
    final isRegistered = AuthRepository.isProgramRegistered(program.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
          child: const Icon(Icons.event_outlined, color: Color(0xFF2E5EAA)),
        ),
        title: Text(program.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitleLines.join(' · ')),
        ),
        isThreeLine: showSeats,
        trailing: isRegistered
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
