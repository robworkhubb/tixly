import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';

import '../models/user_model.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService();

  Future<UserModel> getProfile(String id) async {
    try {
      final docRef = _db.collection('users').doc(id);
      final snap = await docRef.get();

      if (!snap.exists) {
        // se manca, creo default
        final defaults = {
          'displayName': '',
          'avatarPath': null,
          'profileImageUrl': null,
          'darkMode': false,
          'email': '',
        };
        await docRef.set(defaults);
        return UserModel.fromMap(defaults, id);
      }
      return UserModel.fromMap(snap.data()!, id);
    } catch (e) {
      throw Exception('Errore durante il recupero del profilo: $e');
    }
  }

  Future<void> updateDisplayName(String uid, String name) async {
    try {
      await _db.collection('users').doc(uid).update({'displayName': name});
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del nome: $e');
    }
  }

  Future<String> uploadAvatar(String uid, File file) async {
    try {
      // 1. Upload su Supabase
      final avatarPath = await _storage.uploadAvatar(file: file, userId: uid);

      // 2. Genera URL pubblica
      final avatarUrl = _storage.getPublicUrl('avatars', avatarPath);

      // 3. Aggiorna Firestore con entrambi i valori
      await _db.collection('users').doc(uid).update({
        'avatarPath': avatarPath,
        'profileImageUrl': avatarUrl,
      });

      return avatarUrl;
    } catch (e) {
      throw Exception('Errore durante l\'upload dell\'avatar: $e');
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del profilo: $e');
    }
  }

  Future<void> updateDarkMode(String uid, bool on) async {
    try {
      await _db.collection('users').doc(uid).update({'darkMode': on});
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del tema: $e');
    }
  }
}
