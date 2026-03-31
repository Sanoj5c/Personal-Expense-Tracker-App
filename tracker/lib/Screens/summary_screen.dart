import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/expense_model.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _firestoreService = FirestoreService();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  DateTime _selectedMonth = DateTime.now();

  final Map<String, Color> categoryColors = {
    'Food': const Color(0xFFFF6B6B),
    'Transport': const Color(0xFF4ECDC4),
    'Shopping': const Color(0xFF45B7D1),
    'Health': const Color(0xFFFF8E53),
    'Entertainment': const Color(0xFF6C63FF),
    'Bills': const Color(0xFFFFBE0B),
    'Other': const Color(0xFF95A5A6),
  };

  final Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.favorite,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Other': Icons.more_horiz,
  };

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (_selectedMonth.year < DateTime.now().year ||
        _selectedMonth.month < DateTime.now().month) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
    }
  }

  List<Expense> _filterByMonth(List<Expense> expenses) {
    return expenses.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month).toList();
  }

  Map<String, double> _groupByCategory(List<Expense> expenses) {
    final Map<String, double> result = {};
    for (final e in expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text('Monthly Summary',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpenses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = snapshot.data ?? [];
          final filtered = _filterByMonth(allExpenses);
          final grouped = _groupByCategory(filtered);
          final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Color(0xFF6C63FF)),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Color(0xFF6C63FF)),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Total Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Spent',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        'LKR ${NumberFormat('#,##0.00').format(total)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${filtered.length} transactions',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pie Chart
                if (grouped.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Spending by Category',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: grouped.entries.map((entry) {
                                final percent = total > 0
                                    ? (entry.value / total * 100)
                                    : 0.0;
                                return PieChartSectionData(
                                  value: entry.value,
                                  color: categoryColors[entry.key] ??
                                      const Color(0xFF95A5A6),
                                  title: '${percent.toStringAsFixed(1)}%',
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Breakdown
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category Breakdown',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...grouped.entries.map((entry) {
                          final percent =
                              total > 0 ? (entry.value / total) : 0.0;
                          final color = categoryColors[entry.key] ??
                              const Color(0xFF95A5A6);
                          final icon = categoryIcons[entry.key] ??
                              Icons.more_horiz;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(entry.key,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Text(
                                      'LKR ${NumberFormat('#,##0.00').format(entry.value)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: const Column(
                      children: [
                        Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No expenses this month',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}