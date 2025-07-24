import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../../domain/usecases/fetch_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/user_entity.dart';

class ProfileProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth;
  final ProfileService _service;
  final FetchProfileUsecase fetchProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  UserEntity? _profile;
  bool _isLoading = false;

  ProfileProvider({
    fb_auth.FirebaseAuth? auth,
    ProfileService? service,
    required this.fetchProfileUsecase,
    required this.updateProfileUsecase,
  }) : _auth = auth ?? fb_auth.FirebaseAuth.instance,
       _service = service ?? ProfileService();

  UserEntity? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    _profile = await fetchProfileUsecase(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserEntity user) async {
    _isLoading = true;
    notifyListeners();
    await updateProfileUsecase(user);
    _profile = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    final uid = _auth.currentUser!.uid;
    await _service.updateDisplayName(uid, name);
    _profile = _profile!.copyWith(displayName: name);
    notifyListeners();
  }

  Future<void> setAvatar(File file) async {
    final uid = _auth.currentUser!.uid;

    // uploadAvatar ora ritorna il String
    final url = await _service.uploadAvatar(uid, file);

    // aggiornalo anche in memoria
    _profile = _profile!.copyWith(profileImageUrl: url);
    notifyListeners();
  }

  // …

  Future<void> toggleDarkMode(bool on) async {
    final uid = _auth.currentUser!.uid;
    await _service.updateDarkMode(uid, on);
    notifyListeners();
  }
}
