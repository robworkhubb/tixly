import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/supabase_storage_service.dart';

class StorageRepositoryImpl implements StorageRepository {
  final SupabaseStorageService _storageService;

  StorageRepositoryImpl(this._storageService);

  @override
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    try {
      return await _storageService.uploadAvatar(file: file, userId: userId);
    } catch (e) {
      debugPrint('❌ StorageRepositoryImpl.uploadAvatar error: $e');
      rethrow;
    }
  }

  @override
  Future<StorageUploadResult> uploadFile({
    required File file,
    required String bucket,
    required String userId,
    bool isPdf = false,
  }) async {
    try {
      final result = await _storageService.uploadFile(
        file: file,
        bucket: bucket,
        userId: userId,
        isPdf: isPdf,
      );
      return StorageUploadResult.fromMap(result);
    } catch (e) {
      debugPrint('❌ StorageRepositoryImpl.uploadFile error: $e');
      rethrow;
    }
  }

  @override
  String getPublicUrl(String bucket, String path) {
    try {
      return _storageService.getPublicUrl(bucket, path);
    } catch (e) {
      debugPrint('❌ StorageRepositoryImpl.getPublicUrl error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _storageService.deleteFile(bucket, path);
    } catch (e) {
      debugPrint('❌ StorageRepositoryImpl.deleteFile error: $e');
      rethrow;
    }
  }
}
