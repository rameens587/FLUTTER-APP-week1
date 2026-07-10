import 'package:flutter/material.dart';
import '../models/program.dart';

/// Screen 3 — Program Listing.
/// Lets learners browse all available programs, with a simple text
/// search and category filter chips.
class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  String _query = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allPrograms = ProgramRepository.getAll();
    final categories = allPrograms.map((p) => p.category).toSet().toList();

    final filtered = allPrograms.where((p) {
      final matchesQuery =
          p.title.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search programs',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _filterChip(label: 'All', selected: _selectedCategory == null,
                    onSelected: () => setState(() => _selectedCategory = null)),
                for (final category in categories)
                  _filterChip(
                    label: category,
                    selected: _selectedCategory == category,
                    onSelected: () =>
                        setState(() => _selectedCategory = category),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No programs match your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _programCard(context, filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }

  Widget _programCard(BuildContext context, Program program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(program.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${program.category} · ${program.location}\n'
            '${program.seatsAvailable} seats left',
          ),
        ),
        isThreeLine: true,
        trailing: program.isRegistered
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          '/program-details',
          arguments: program.id,
        ),
      ),
    );
  }
}
