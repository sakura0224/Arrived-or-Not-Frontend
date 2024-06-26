import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StateNotifier extends ChangeNotifier {
  XFile? _image;
  bool _isLoading = false;

  XFile? get image => _image;
  bool get isLoading => _isLoading;

  void setImage(XFile image) {
    _image = image;
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
