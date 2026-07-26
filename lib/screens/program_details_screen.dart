import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/program.dart';
import '../services/auth_repository.dart';

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
  final _registrationFormKey = GlobalKey<FormState>();
  final _feedbackFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  double _rating = 4;
  bool _isRegistering = false;
  bool _isSubmittingFeedback = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha((0.1 * 255).round()),
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
          if (!AuthRepository.isProgramRegistered(program.id)) ...[
            Form(
              key: _registrationFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text('Register to join this program',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!AuthRepository.isValidEmail(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isRegistering
                        ? null
                        : () async {
                            if (!_registrationFormKey.currentState!.validate()) {
                              return;
                            }

                            setState(() => _isRegistering = true);
                            await Future.delayed(const Duration(milliseconds: 600));
                            await ProgramRepository.toggleRegistration(program.id);
                            if (!mounted) return;
                            setState(() => _isRegistering = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful!')),
                            );
                          },
                    icon: _isRegistering
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.how_to_reg_outlined),
                    label: Text(_isRegistering ? 'Registering...' : 'Register for this program'),
                  ),
                ],
              ),
            ),
          ] else ...[
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
            Form(
              key: _feedbackFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts about this program...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your feedback';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isSubmittingFeedback
                        ? null
                        : () async {
                            if (!_feedbackFormKey.currentState!.validate()) {
                              return;
                            }
                            setState(() => _isSubmittingFeedback = true);
                            await Future.delayed(const Duration(milliseconds: 400));
                            if (!mounted) return;
                            setState(() => _isSubmittingFeedback = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thanks for your feedback!')),
                            );
                            _feedbackController.clear();
                          },
                    child: _isSubmittingFeedback
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Feedback'),
                  ),
                ],
              ),
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
