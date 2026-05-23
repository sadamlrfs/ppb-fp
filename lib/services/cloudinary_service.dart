import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/config/cloudinary_config.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      CloudinaryConfig.cloudName,
      CloudinaryConfig.uploadPreset,
      cache: false,
    );
  }

  Future<String> uploadImage(String filePath,
      {String folder = 'journals'}) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        filePath,
        folder: 'mindease/$folder',
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }

  Future<String> uploadAudio(String filePath,
      {String folder = 'meditation'}) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        filePath,
        folder: 'mindease/$folder',
        resourceType: CloudinaryResourceType.Auto,
      ),
    );
    return response.secureUrl;
  }
}
