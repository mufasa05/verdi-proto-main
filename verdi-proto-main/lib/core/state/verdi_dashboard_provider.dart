import 'package:flutter/foundation.dart';

import '../data/verdi_mock_repository.dart';
import '../models/verdi_dashboard_data.dart';

class VerdiDashboardProvider extends ChangeNotifier {
  final VerdiMockRepository repository;

  VerdiDashboardProvider({required this.repository});

  VerdiDashboardData? _data;
  VerdiDashboardData? get data => _data;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _data = repository.getDashboardData();

    _loading = false;
    notifyListeners();
  }
}