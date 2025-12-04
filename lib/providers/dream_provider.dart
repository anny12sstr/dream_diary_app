// ignore_for_file: unnecessary_null_comparison
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dream_diary_app/services/dream_repository.dart';
import 'package:dream_diary_app/models/dream_model.dart';

class DreamProvider with ChangeNotifier {
  final IDreamRepository _repository = DreamRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Dream> _dreams = [];
  List<Dream> _filteredDreams = [];

  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  String? _currentCategory;
  String? _currentEmotion;

  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Dream> get dreams => _dreams;
  List<Dream> get drafts => _dreams.where((d) => d.isDraft).toList();
  int get totalFilteredDreamsCount => _filteredDreams.length;

  DreamProvider() {
    _fetchDreams();
  }

  Future<void> _fetchDreams() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _dreams = await _repository.getDreams(user.uid);
      _reApplyCurrentFilters(); 
      _isLoading = false;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch dreams: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  // МЕТОД ФІЛЬТРАЦІЇ
  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? emotion,
  }) {
    _currentStartDate = startDate;
    _currentEndDate = endDate;
    _currentCategory = category;
    _currentEmotion = emotion;

    _reApplyCurrentFilters();
  }

  // Внутрішній метод для повторного застосування фільтрів
  void _reApplyCurrentFilters() {
    _filteredDreams = _dreams.where((dream) {
      if (dream.isDraft) return false;

      if (_currentStartDate != null) {
        if (dream.date.isBefore(_currentStartDate!)) return false;
      }
      if (_currentEndDate != null) {
        if (dream.date.isAfter(_currentEndDate!.add(const Duration(days: 1)))) return false;
      }
      if (_currentCategory != null && _currentCategory != 'All Categories') {
        if (dream.category != _currentCategory) return false;
      }
      if (_currentEmotion != null && _currentEmotion != 'All Emotions') {
        if (dream.emotion != _currentEmotion) return false;
      }
      return true;
    }).toList();

    notifyListeners();
  }

  // ДОДАВАННЯ
  Future<void> addDream({
    required String title,
    required String description,
    required String category,
    required String emotion,
    required List<String> tags,
    required double rating,
    bool isDraft = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final Map<String, dynamic> dreamData = {
        'title': title,
        'description': description,
        'category': category,
        'emotion': emotion,
        'tags': tags,
        'rating': rating,
        'date': Timestamp.now(),
        'isDraft': isDraft,
      };

      await _repository.addDream(user.uid, dreamData);
      await _fetchDreams(); 
    } catch (e) {
      _error = 'Failed to add dream: $e';
      notifyListeners();
    }
  }

  // РЕДАГУВАННЯ
  Future<void> updateDream({
    required String id,
    required String title,
    required String description,
    required String category,
    required String emotion,
    required List<String> tags,
    required double rating,
    bool isDraft = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Оновлення ЛОКАЛЬНО
    final index = _dreams.indexWhere((d) => d.id == id);
    if (index != -1) {
      final oldDream = _dreams[index];
      _dreams[index] = Dream(
        id: id,
        title: title,
        description: description,
        category: category,
        emotion: emotion,
        tags: tags,
        rating: rating,
        isDraft: isDraft,
        date: oldDream.date, 
      );
      _reApplyCurrentFilters(); 
    }

    try {
      // Оновлення в БАЗІ (фоново)
      final Map<String, dynamic> updatedData = {
        'title': title,
        'description': description,
        'category': category,
        'emotion': emotion,
        'tags': tags,
        'rating': rating,
        'isDraft': isDraft,
      };
      await _repository.updateDream(user.uid, id, updatedData);
    } catch (e) {
      _error = 'Failed to update dream: $e';
      _fetchDreams();
    }
  }

  // ВИДАЛЕННЯ
  Future<void> deleteDream(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Видалення ЛОКАЛЬНО
    _dreams.removeWhere((dream) => dream.id == id);
    _reApplyCurrentFilters(); 

    try {
      // Видалення з БАЗИ (фоново)
      await _repository.deleteDream(user.uid, id);
    } catch (e) {
      _error = 'Failed to delete dream: $e';
      _fetchDreams(); 
    }
  }

  // РЕЙТИНГ 
  Future<void> updateDreamRating(String id, double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Оновлення ЛОКАЛЬНО
    final index = _dreams.indexWhere((d) => d.id == id);
    if (index != -1) {
      final old = _dreams[index];
      _dreams[index] = Dream(
        id: old.id,
        title: old.title,
        description: old.description,
        date: old.date,
        category: old.category,
        emotion: old.emotion,
        rating: rating, 
        tags: old.tags,
        isDraft: old.isDraft,
      );
      _reApplyCurrentFilters();
    }

    try {
      // Оновлюємо в БАЗІ
      await _repository.updateDreamRating(user.uid, id, rating);
    } catch (e) {
      _error = 'Failed to update rating: $e';
      _fetchDreams();
    }
  }

  List<Dream> getDreamsForPage(int page, int itemsPerPage) {
    int startIndex = (page - 1) * itemsPerPage;
    int endIndex = min(startIndex + itemsPerPage, _filteredDreams.length);
    if (startIndex >= _filteredDreams.length) return [];
    return _filteredDreams.sublist(startIndex, endIndex);
  }
}