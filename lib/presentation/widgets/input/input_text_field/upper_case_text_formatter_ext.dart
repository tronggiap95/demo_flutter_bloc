import 'package:flutter/services.dart';

/// capitalize the first letter of each word
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: _capitalizeWords(newValue.text),
      selection: newValue.selection,
    );
  }
}

String _capitalizeWords(String text) {
  // Split the text into words, capitalize the first letter of each word, and join them back
  List<String> words = text.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
    }
  }
  return words.join(' ');
}
