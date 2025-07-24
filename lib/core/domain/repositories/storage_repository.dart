import 'dart:io';

abstract class StorageRepository {
  /// Upload un avatar e restituisce il path del file
  Future<String> uploadAvatar({required File file, required String userId});

  /// Upload un file generico e restituisce path e URL pubblica
  Future<StorageUploadResult> uploadFile({
    required File file,
    required String bucket,
    required String userId,
    bool isPdf = false,
  });

  /// Genera URL pubblica per un file
  String getPublicUrl(String bucket, String path);

  /// Elimina un file
  Future<void> deleteFile(String bucket, String path);
}

class StorageUploadResult {
  final String path;
  final String url;

  const StorageUploadResult({required this.path, required this.url});

  factory StorageUploadResult.fromMap(Map<String, String> map) {
    return StorageUploadResult(path: map['path']!, url: map['url']!);
  }

  Map<String, String> toMap() {
    return {'path': path, 'url': url};
  }
}
