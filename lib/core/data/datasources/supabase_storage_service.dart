import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;

  /// Upload avatar nel bucket 'avatars'
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    try {
      final bucket = 'avatars';
      final ext = path.extension(file.path);
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
      final filePath = '$userId/$fileName';

      debugPrint('📤 Uploading avatar: $filePath');

      // Leggi il file come bytes
      final Uint8List fileBytes = await file.readAsBytes();

      // Upload usando i bytes
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      debugPrint('✅ Avatar uploaded successfully: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Upload generico file (es. post media, ticket) in bucket specificato
  Future<Map<String, String>> uploadFile({
    required File file,
    required String bucket,
    required String userId,
    bool isPdf = false,
  }) async {
    try {
      final ext = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final filePath = '$userId/$fileName';

      debugPrint('📤 Uploading file to $bucket: $filePath');

      // Leggi il file come bytes
      final Uint8List fileBytes = await file.readAsBytes();

      // Upload usando i bytes
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = getPublicUrl(bucket, filePath);
      debugPrint('✅ File uploaded successfully. URL: $publicUrl');

      return {'path': filePath, 'url': publicUrl};
    } catch (e) {
      debugPrint('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Genera URL pubblica per un file
  String getPublicUrl(String bucket, String path) {
    try {
      // Costruisci l'URL pubblica manualmente per evitare problemi di autenticazione
      final url =
          'https://gpjdeuihwrmdqxzcmxxs.supabase.co/storage/v1/object/public/$bucket/$path';
      debugPrint('🔗 Generated public URL: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Error generating public URL: $e');
      rethrow;
    }
  }

  /// Elimina un file
  Future<void> deleteFile(String bucket, String path) async {
    try {
      debugPrint('🗑️ Deleting file from $bucket: $path');
      await _supabase.storage.from(bucket).remove([path]);
      debugPrint('✅ File deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      rethrow;
    }
  }
}
