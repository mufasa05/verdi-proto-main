import 'package:flutter/foundation.dart';
import '../widgets/state_view.dart';

class PageViewModel extends ChangeNotifier {
  ViewState _state = ViewState.content;
  String? _title;
  String? _message;

  ViewState get state => _state;
  String? get title => _title;
  String? get message => _message;

  void setLoading({String? title, String? message}) {
    _state = ViewState.loading;
    _title = title;
    _message = message;
    notifyListeners();
  }

  void setEmpty({String? title, String? message}) {
    _state = ViewState.empty;
    _title = title;
    _message = message;
    notifyListeners();
  }

  void setError({String? title, String? message}) {
    _state = ViewState.error;
    _title = title;
    _message = message;
    notifyListeners();
  }

  void setContent() {
    _state = ViewState.content;
    _title = null;
    _message = null;
    notifyListeners();
  }
}