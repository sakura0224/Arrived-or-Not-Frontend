import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StateNotifier extends ChangeNotifier {
  XFile? _image; // image_picker返回的图片
  bool _isLoading = false; // 是否正在加载

  XFile? get image => _image;
  bool get isLoading => _isLoading;

  void setImage(XFile image) {
    // 设置图片
    _image = image;
    notifyListeners();
  }

  set isLoading(bool isLoading) {
    // 设置加载状态
    _isLoading = isLoading;
    notifyListeners();
  }
}
