import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService();

  UserModel? _user;
  UserModel? get user => _user;

  final Map<String, UserModel> _cache = {};
  Map<String, UserModel> get cache => Map.unmodifiable(_cache);

  Future<void> loadUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        String? avatarUrl;

        if (data['avatarPath'] != null) {
          avatarUrl = _storage.getPublicUrl('avatars', data['avatarPath']);
        } else if (data['profileImageUrl'] != null) {
          avatarUrl = data['profileImageUrl'];
        }

        _user = UserModel(
          id: doc.id,
          displayName: data['displayName'] ?? '',
          profileImageUrl: avatarUrl,
          email: data['email'] ?? '',
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadProfile(String uid) async {
    if (_cache.containsKey(uid)) return;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        String? avatarUrl;

        if (data['avatarPath'] != null) {
          avatarUrl = _storage.getPublicUrl('avatars', data['avatarPath']);
        } else if (data['profileImageUrl'] != null) {
          avatarUrl = data['profileImageUrl'];
        }

        _cache[uid] = UserModel.fromMap({
          ...data,
          'profileImageUrl': avatarUrl,
        }, doc.id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? avatarPath}) async {
    if (_user == null) return;
    final uid = _user!.id;
    final data = <String, dynamic>{};

    if (displayName != null) data['displayName'] = displayName;
    if (avatarPath != null) {
      data['avatarPath'] = avatarPath;
      final avatarUrl = _storage.getPublicUrl('avatars', avatarPath);
      data['profileImageUrl'] = avatarUrl;
    }

    try {
      await _db.collection('users').doc(uid).update(data);
      _user = _user!.copyWith(
        displayName: displayName,
        profileImageUrl: data['profileImageUrl'],
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshProfile(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final data = snap.data();
      if (data == null) return;

      String? avatarUrl;
      if (data['avatarPath'] != null) {
        avatarUrl = _storage.getPublicUrl('avatars', data['avatarPath']);
      } else if (data['profileImageUrl'] != null) {
        avatarUrl = data['profileImageUrl'];
      }

      if (_cache.containsKey(uid)) {
        _cache[uid] = _cache[uid]!.copyWith(profileImageUrl: avatarUrl);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearUser() {
    _user = null;
    _cache.clear();
    notifyListeners();
  }
}
