import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../services/auth_repository.dart';

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
  static final List<Program> _programs = <Program>[];
  static bool _initialized = false;
  static Future<void>? _initializationFuture;

  static Future<void> initialize() {
    _initializationFuture ??= _loadPrograms();
    return _initializationFuture!;
  }

  static Future<void> _loadPrograms() async {
    try {
      final raw = await rootBundle.loadString('assets/data/programs.json');
      final decoded = json.decode(raw) as List<dynamic>;
      _programs
        ..clear()
        ..addAll(
          decoded.map((item) {
            final map = item as Map<String, dynamic>;
            return Program(
              id: map['id'] as String,
              title: map['title'] as String,
              category: map['category'] as String,
              description: map['description'] as String,
              date: DateTime.parse(map['date'] as String),
              location: map['location'] as String,
              seatsAvailable: map['seatsAvailable'] as int,
            );
          }),
        );
    } catch (_) {
      _programs
        ..clear()
        ..addAll(_fallbackPrograms);
    }

    _initialized = true;
  }

  static List<Program> getAll() {
    if (!_initialized) {
      initialize();
      return List.unmodifiable(_fallbackPrograms);
    }
    return List.unmodifiable(_programs);
  }

  static Program getById(String id) {
    if (!_initialized) {
      initialize();
      return _fallbackPrograms.firstWhere(
        (p) => p.id == id,
        orElse: () => _fallbackPrograms.first,
      );
    }

    return _programs.firstWhere(
      (p) => p.id == id,
      orElse: () => _fallbackPrograms.firstWhere(
        (p) => p.id == id,
        orElse: () => _fallbackPrograms.first,
      ),
    );
  }

  static List<Program> getRegisteredPrograms() {
    return _programs
        .where((program) => AuthRepository.isProgramRegistered(program.id))
        .toList();
  }

  static List<Program> getCurrentlyHappeningPrograms() {
    return _programs
        .where((program) =>
            program.date.isBefore(DateTime.now().add(const Duration(days: 7))) &&
            AuthRepository.isProgramRegistered(program.id))
        .toList();
  }

  static List<Program> getUpcomingPrograms() {
    return _programs
        .where((program) =>
            !AuthRepository.isProgramRegistered(program.id) &&
            program.date.isAfter(DateTime.now()))
        .toList()
        .take(4)
        .toList();
  }

  static Future<void> toggleRegistration(String id) async {
    await AuthRepository.toggleProgramRegistration(id);
  }

  static final List<Program> _fallbackPrograms = [
    Program(
      id: 'p1',
      title: 'AI Product Launch Workshop',
      category: 'Workshop',
      description: 'Sample fallback program for offline or missing data.',
      date: DateTime.now().add(const Duration(days: 4)),
      location: 'Innovation Lab — Room 4',
      seatsAvailable: 18,
    ),
    Program(
      id: 'p2',
      title: 'Career Readiness Bootcamp',
      category: 'Bootcamp',
      description: 'Sample fallback program for offline or missing data.',
      date: DateTime.now().add(const Duration(days: 6)),
      location: 'Excelerate Hub — Room 204',
      seatsAvailable: 12,
    ),
  ];
}
