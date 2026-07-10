import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/program.dart';

/// Screen 4 — Program Details / Profile.
/// Shows full program info, lets a learner register, and — once
/// registered — submit feedback (per the App Proposal's "Feedback Form"
/// core feature).
class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final _feedbackController = TextEditingController();
  double _rating = 4;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = ProgramRepository.getById(widget.programId);
    final dateLabel = DateFormat('EEEE, MMM d • h:mm a').format(program.date);

    return Scaffold(
      appBar: AppBar(title: const Text('Program Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.event, size: 48, color: Color(0xFF2E5EAA)),
          ),
          const SizedBox(height: 16),
          Text(program.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Chip(label: Text(program.category)),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today_outlined, dateLabel),
          _infoRow(Icons.location_on_outlined, program.location),
          _infoRow(Icons.people_outline,
              '${program.seatsAvailable} seats available'),
          const SizedBox(height: 16),
          Text('About this program',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(program.description,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(program.isRegistered
                ? Icons.check_circle_outline
                : Icons.how_to_reg_outlined),
            label: Text(
                program.isRegistered ? 'Registered' : 'Register for this program'),
            onPressed: () {
              setState(() => ProgramRepository.toggleRegistration(program.id));
            },
          ),
          if (program.isRegistered) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Leave Feedback',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts about this program...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thanks for your feedback!')),
                );
                _feedbackController.clear();
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
