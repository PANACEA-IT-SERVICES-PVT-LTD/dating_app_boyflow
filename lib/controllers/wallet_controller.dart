import 'package:flutter/foundation.dart';
import 'package:boy_flow/models/wallet_transaction.dart';
import 'package:boy_flow/services/api_service.dart';

class WalletController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  bool _isLoading = false;
  String? _error;
  List<WalletTransaction> _transactions = [];
  String? _startDate;
  String? _endDate;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  String? get startDate => _startDate;
  String? get endDate => _endDate;

  // Set date range
  void setDateRange(String start, String end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Clear date range
  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    _transactions = [];
    _error = null;
    notifyListeners();
  }

  // Fetch wallet transactions by date range
  Future<void> fetchTransactionsByDate({
    required String startDate,
    required String endDate,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();

    try {
      final transactions = await _apiService.getWalletTransactionsByDate(
        startDate,
        endDate,
      );

      // Sort transactions by date (newest first)
      _transactions = transactions
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _error = null;
    } catch (e) {
      _transactions = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh transactions
  Future<void> refreshTransactions() async {
    if (_startDate != null && _endDate != null) {
      await fetchTransactionsByDate(startDate: _startDate!, endDate: _endDate!);
    }
  }

  // Check if there are transactions
  bool get hasTransactions => _transactions.isNotEmpty;

  // Check if date range is selected
  bool get hasDateRange => _startDate != null && _endDate != null;

  // Get formatted date range for display
  String get formattedDateRange {
    if (_startDate == null || _endDate == null) {
      return 'No date range selected';
    }
    return '$_startDate to $_endDate';
  }
}
