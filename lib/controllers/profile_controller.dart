import 'package:flutter/foundation.dart';
import 'package:boy_flow/models/profile_model.dart';
import 'package:boy_flow/services/api_service.dart';

class ProfileController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  ProfileModel? _profileData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProfileModel? get profileData => _profileData;

  Future<void> fetchProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profileData = await _apiService.getProfileDetails();
      _error = null;
    } catch (e) {
      _profileData = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
