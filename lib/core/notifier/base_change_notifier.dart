import 'package:flutter/foundation.dart';

class BaseChangeNotifier extends ChangeNotifier {
  bool _mounted = true;
  bool get isMounted => _mounted;

  BaseChangeNotifier() {
    initState();
  }

  void initState() {}

  @override
  void notifyListeners() {
    if (_mounted) super.notifyListeners();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
