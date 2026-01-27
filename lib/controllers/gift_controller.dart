import 'package:flutter/foundation.dart';
import 'package:Boy_flow/models/gift.dart';
import 'package:Boy_flow/models/send_gift_response.dart';
import 'package:Boy_flow/services/api_service.dart';

class GiftController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Gift> _gifts = [];
  int _maleCoinBalance = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Gift> get gifts => List.unmodifiable(_gifts);
  int get maleCoinBalance => _maleCoinBalance;

  void setMaleCoinBalance(int balance) {
    _maleCoinBalance = balance;
    notifyListeners();
  }

  Future<void> fetchAllGifts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gifts = await _apiService.getAllGifts();
      _error = null;
    } catch (e) {
      _gifts = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SendGiftResponse?> sendGiftToFemale({
    required String femaleUserId,
    required String giftId,
    required int giftCoinValue,
  }) async {
    if (_isLoading) return null;

    // Check if user has sufficient balance
    if (_maleCoinBalance < giftCoinValue) {
      _error =
          'Insufficient balance. You need $giftCoinValue coins but have $_maleCoinBalance coins.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.sendGift(femaleUserId, giftId);

      // Update male coin balance from response
      _maleCoinBalance = response.maleCoinBalance;
      _error = null;

      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
