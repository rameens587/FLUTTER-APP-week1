import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/program.dart';
import '../services/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AuthRepository.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      await AuthRepository.updateProfileImagePath(pickedFile.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final registeredPrograms = ProgramRepository.getRegisteredPrograms();
    final currentlyHappening = ProgramRepository.getCurrentlyHappeningPrograms();
    final upcomingPrograms = ProgramRepository.getUpcomingPrograms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await AuthRepository.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                      backgroundImage: AuthRepository.profileImagePath != null
                          ? FileImage(File(AuthRepository.profileImagePath!))
                          : null,
                      child: AuthRepository.profileImagePath == null
                          ? Text(
                              AuthRepository.displayName.isNotEmpty
                                  ? AuthRepository.displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _isEditingName
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Your name'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              await AuthRepository.updateDisplayName(
                                  _nameController.text.trim().isEmpty
                                      ? AuthRepository.displayName
                                      : _nameController.text.trim());
                              setState(() {
                                _isEditingName = false;
                              });
                            },
                            icon: const Icon(Icons.check),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AuthRepository.displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => _isEditingName = true),
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit name',
                          ),
                        ],
                      ),
                const SizedBox(height: 8),
                Text(
                  '${AuthRepository.currentUserEmail ?? 'No email signed in'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _statsRow(registeredPrograms.length, currentlyHappening.length, upcomingPrograms.length),
          const SizedBox(height: 20),
          _programSection('Currently happening', currentlyHappening),
          const SizedBox(height: 16),
          _programSection('Coming up', upcomingPrograms),
          const SizedBox(height: 16),
          _programSection('Signed up programs', registeredPrograms),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/programs');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Programs'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _statsRow(int signedUpCount, int liveCount, int upcomingCount) {
    return Row(
      children: [
        Expanded(
          child: _statCard('Signed up', signedUpCount.toString()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('Live now', liveCount.toString()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard('Upcoming', upcomingCount.toString()),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _programSection(String title, List<Program> programs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (programs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Nothing here yet — register for a program to see it here.'),
          )
        else
          ...programs.map(
            (program) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.12 * 255).round()),
                    child: const Icon(Icons.event, color: Color(0xFF2E5EAA)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(program.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(program.category, style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
