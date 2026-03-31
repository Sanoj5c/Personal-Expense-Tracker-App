import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to user's expenses collection
  CollectionReference _expensesRef(String userId) {
    return _db.collection('users').doc(userId).collection('expenses');
  }

  // Add expense
  Future<void> addExpense(String userId, Expense expense) async {
    await _expensesRef(userId).add(expense.toMap());
  }

  // Delete expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _expensesRef(userId).doc(expenseId).delete();
  }

  // Get all expenses as a stream (real-time updates)
  Stream<List<Expense>> getExpenses(String userId) {
    return _expensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}