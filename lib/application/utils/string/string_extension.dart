extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String spaceSeparateNumbers() {
    final result = replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
    return result;
  }

  String spaceToNewline() {
    return replaceAll(' ', '\n');
  }

  String replaceWithSeparator(
      {List<String> patterns = const [],
      String separator = '-',
      bool isLowerCase = true}) {
    if (isNullOrEmpty() || patterns.isEmpty) return this;
    var output = this;
    for (String pattern in patterns) {
      final regex = RegExp(pattern);
      output = output.replaceAll(regex, separator);
    }
    return isLowerCase ? output.toLowerCase() : output;
  }

  String removeSpecialCharacters() {
    return replaceAll((RegExp(r'[!@#$%^&*(),.?":{}|<>]')), '');
  }

  bool isNullOrEmpty() => isEmpty;

  bool isNotNullOrEmpty() => !isNullOrEmpty();

  String toQuoteString() {
    return "'$this'";
  }
}
