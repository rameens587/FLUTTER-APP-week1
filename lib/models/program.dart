/// Represents a program or event that a learner can browse, register for,
/// and leave feedback on.
class Program {
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime date;
  final String location;
  final int seatsAvailable;
  final bool isRegistered;

  const Program({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.date,
    required this.location,
    required this.seatsAvailable,
    this.isRegistered = false,
  });

  Program copyWith({bool? isRegistered}) {
    return Program(
      id: id,
      title: title,
      category: category,
      description: description,
      date: date,
      location: location,
      seatsAvailable: seatsAvailable,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}

/// A very small in-memory data source standing in for a future backend
/// (e.g. Firebase / REST API). Swapping this out is the main integration
/// point for Week 2+ work.
class ProgramRepository {
  static final List<Program> _programs = [
    Program(
      id: 'p1',
      title: 'Intro to Flutter Workshop',
      category: 'Workshop',
      description:
          'A hands-on session covering widgets, state management, and '
          'building your first cross-platform screen.',
      date: DateTime.now().add(const Duration(days: 3)),
      location: 'Online — Zoom',
      seatsAvailable: 24,
    ),
    Program(
      id: 'p2',
      title: 'Career Readiness Bootcamp',
      category: 'Bootcamp',
      description:
          'Resume reviews, mock interviews, and networking practice with '
          'industry mentors.',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Excelerate Hub — Room 204',
      seatsAvailable: 12,
    ),
    Program(
      id: 'p3',
      title: 'Data Analytics Info Session',
      category: 'Info Session',
      description:
          'Learn what the Data Analytics track covers and how to apply '
          'for the next cohort.',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Online — Google Meet',
      seatsAvailable: 50,
    ),
  ];

  static List<Program> getAll() => List.unmodifiable(_programs);

  static Program getById(String id) =>
      _programs.firstWhere((p) => p.id == id);

  static void toggleRegistration(String id) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index != -1) {
      _programs[index] =
          _programs[index].copyWith(isRegistered: !_programs[index].isRegistered);
    }
  }
}
