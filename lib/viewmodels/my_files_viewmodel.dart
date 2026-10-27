import 'package:flutter/material.dart';
import '../models/my_file_model.dart';
import '../services/my_files_service.dart';
import '../services/auth_service.dart';

class MyFilesViewModel extends ChangeNotifier {
  final MyFilesService _myFilesService = MyFilesService();
  final AuthService _authService = AuthService();
  
  List<MyFileModel> _galleryFiles = [];
  String _gallerySearchQuery = '';
  List<MyFileModel> get galleryFiles {
    if (_gallerySearchQuery.isEmpty) return _galleryFiles;
    return _galleryFiles.where((f) => f.fileName.toLowerCase().contains(_gallerySearchQuery.toLowerCase())).toList();
  }

  void setGallerySearchQuery(String query) {
    _gallerySearchQuery = query;
    notifyListeners();
  }

  List<MyFileModel> _cadFiles = [];
  String _cadSearchQuery = '';
  List<MyFileModel> get cadFiles {
    if (_cadSearchQuery.isEmpty) return _cadFiles;
    return _cadFiles.where((f) => f.fileName.toLowerCase().contains(_cadSearchQuery.toLowerCase())).toList();
  }

  void setCadSearchQuery(String query) {
    _cadSearchQuery = query;
    notifyListeners();
  }

  bool _isLoadingGallery = false;
  bool get isLoadingGallery => _isLoadingGallery;

  bool _isLoadingCad = false;
  bool get isLoadingCad => _isLoadingCad;

  String? _galleryError;
  String? get galleryError => _galleryError;

  String? _cadError;
  String? get cadError => _cadError;

  String? _whatsappNumber;
  String? get whatsappNumber => _whatsappNumber;

  String? _userId;

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (userId == null) {
        _galleryFiles = [];
        _cadFiles = [];
        _galleryError = null;
        _cadError = null;
        _whatsappNumber = null;
      }
      notifyListeners();
    }
  }

  Future<void> fetchFiles() async {
    if (_userId == null) {
      _galleryError = 'User not logged in';
      _cadError = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoadingGallery = true;
    _isLoadingCad = true;
    _galleryError = null;
    _cadError = null;
    notifyListeners();

    try {
      final profile = await _authService.getProfile(_userId!);
      _whatsappNumber = profile.phone;
      final cadGalleryName = profile.cadGalleryName;
      final cadGalleryStatus = profile.cadGalleryStatus;

      if (cadGalleryName.isNotEmpty && cadGalleryStatus == '1') {
        final files = await _myFilesService.getCustomerS3Files(cadGalleryName);
        _galleryFiles = files['mygallery'] ?? [];
        _cadFiles = files['mycad'] ?? [];
      } else {
        _galleryError = 'Gallery disabled or not configured in profile';
        _cadError = 'Gallery disabled or not configured in profile';
      }
    } catch (e) {
      _galleryError = e.toString();
      _cadError = e.toString();
    } finally {
      _isLoadingGallery = false;
      _isLoadingCad = false;
      notifyListeners();
    }
  }

  Future<void> fetchGalleryFiles() async {
    await fetchFiles();
  }

  Future<void> fetchCadFiles() async {
    await fetchFiles();
  }
}
