import 'package:deduct_ai/model/case.dart';
import 'package:flutter/material.dart';

class CaseProvider extends ChangeNotifier {
  List<Case> _cases = [];

  List<Case> get cases => _cases;

  void addCase(Case newCase) {
    _cases.add(newCase);
    notifyListeners();
  }

  void removeCase(Case existingCase) {
    _cases.remove(existingCase);
    notifyListeners();
  }
}
