import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DownloadService {
  Future<String> downloadFile(String url, String fileName) async {
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$fileName';

    try {
      await dio.download(url, path);
      return path;
    } catch (e) {
      throw Exception('خطا در دانلود فایل: $e');
    }
  }
}

class UploadService {
  final Dio _dio = Dio();

  Future<void> uploadFile(String filePath, String uploadUrl) async {
    final fileName = path.basename(filePath);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    try {
      final response = await _dio.post(uploadUrl, data: formData);
      print('آپلود موفق: ${response.data}');
    } catch (e) {
      print('خطا در آپلود فایل: $e');
    }
  }
}
