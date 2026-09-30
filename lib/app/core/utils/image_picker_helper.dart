import 'package:image_picker/image_picker.dart';
import 'package:adventureme/app/core/utils/logger.dart';

class ImagePickerHelper {
  static Future<XFile?> pickSingleFile({
    required ImageSource imageSource,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: imageSource,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (pickedImage != null) {
      Log.i(pickedImage);
      return pickedImage;
    } else {
      Log.e("Picked file is null");
      return null;
    }
  }

  static Future<List<XFile>?> pickMultiFile() async {
    final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      Log.i(pickedImages);
      return pickedImages;
    } else {
      Log.e("Picked file is null");
      return null;
    }
  }
}
