// Purpose: Handles data related to the user's recycling history

import 'package:flutter/material.dart';
import 'package:flutter_create_test/backend/models/recycling_history.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';

class RecyclingHistoryController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<RecyclingHistory> _historyList = [];

  List<RecyclingHistory> get historyList => _historyList;

  // load all user's recycling history from firestore
  Future<void> loadRecyclingHistory(String userId) async {
    _historyList = await _firestoreService.getRecyclingHistory(userId);
    notifyListeners();
  }

  // adds a new entry of user's recycling history to firestore
  Future<void> addHistory(String userId, RecyclingHistory history) async {
    await _firestoreService.addRecyclingHistory(userId, history);
    await loadRecyclingHistory(userId); // refresh list after adding
  }
}
