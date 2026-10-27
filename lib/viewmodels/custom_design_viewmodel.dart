import 'package:flutter/foundation.dart';
import '../services/custom_design_service.dart';

class CustomDesignViewModel extends ChangeNotifier {
  final CustomDesignService _customDesignService = CustomDesignService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitDesignForm({
    required String userId,
    required String company,
    required String name,
    required String email,
    required String contact,
    required String msg,
    required String frame,
    String budget = "",
    required String referenceNumber,
    required String size,
    required String metal,
    required String centerDiamond,
    String matchingPair = "",
    String nbLength = "",
    String metalColor = "",
    String customerStoneDetails = "",
    List<String>? imagePaths,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final Map<String, dynamic> data = {
        "user_id": userId,
        "company": company,
        "name": name,
        "email": email,
        "contact": contact,
        "msg": msg,
        "frame": frame,
        "budget": budget,
        "reference_number": referenceNumber,
        "size": size,
        "metal": metal,
        "center_diamond": centerDiamond,
        "matching_pair": matchingPair,
        "nb_length": nbLength,
        "metal_color": metalColor,
        "customer_stone_details": customerStoneDetails,
      };

      await _customDesignService.submitCustomDesign(data, imagePaths: imagePaths);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
