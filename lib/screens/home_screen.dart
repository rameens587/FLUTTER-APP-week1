import 'package:flutter/material.dart';
import '../models/program.dart';

/// Screen 2 — Home Dashboard.
/// Shows announcements and a quick preview of upcoming programs, with
/// navigation into the full Program Listing screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = ProgramRepository.getAll().take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(context),
          const SizedBox(height: 20),
          _announcementBanner(context),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Programs',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/programs'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final program in upcoming)
            _programPreviewTile(context, program),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/programs');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_outlined), label: 'Programs'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back 👋',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Here is what is happening in your programs today.',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _announcementBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'New: Career Readiness Bootcamp registration is now open!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _programPreviewTile(BuildContext context, Program program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: const Icon(Icons.event_outlined, color: Color(0xFF2E5EAA)),
        ),
        title: Text(program.title),
        subtitle: Text(program.category),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          '/program-details',
          arguments: program.id,
        ),
      ),
    );
  }
}
