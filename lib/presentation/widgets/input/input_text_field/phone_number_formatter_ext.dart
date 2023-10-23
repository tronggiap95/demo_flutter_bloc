import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int oldSelectionIndex = oldValue.selection.end;
    int usedSubstringIndex = 0;
    //IF CURSOR TEXT FULL MASK OF ###-###-#### AND STAND IN THE END.
    if (selectionIndex > 10) {
      return TextEditingValue(
        text: oldValue.text.toString(),
        selection: TextSelection.collapsed(offset: oldValue.selection.end),
      );
    }
    // DELETE/ UPDATE WHEN CURSOR IS IN THE MIDDLE
    if (selectionIndex < newTextLength) {
      //CURSOR IS AT THE BEGINING
      if (oldSelectionIndex == 0) {
        final StringBuffer newText = StringBuffer();
        if (newTextLength >= 4) {
          newText
              .write('${newValue.text.substring(0, usedSubstringIndex = 3)}-');
          if (newValue.selection.end >= 3) selectionIndex++;
        }
        if (newTextLength >= 7) {
          newText
              .write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
          if (newValue.selection.end >= 6) selectionIndex++;
        }

        if (newTextLength > 9) {
          if (newTextLength >= usedSubstringIndex) {
            newText.write(newValue.text
                .substring(usedSubstringIndex, usedSubstringIndex + 4));
          }
        } else {
          if (newTextLength >= usedSubstringIndex) {
            newText.write(newValue.text.substring(usedSubstringIndex));
          }
        }
        return TextEditingValue(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: oldSelectionIndex + 1),
        );
      }
      final isSeprate =
          oldValue.text.substring(oldSelectionIndex - 1, oldSelectionIndex) ==
              '-';
      final isSame = oldValue.text.replaceAll('-', '') == newValue.text;
      // IF CUSOR IS AFTER '-' CHARACTER.
      if (isSeprate && isSame) {
        return TextEditingValue(
          text: oldValue.text.toString(),
          selection: TextSelection.collapsed(offset: oldSelectionIndex - 1),
        );
      }
      //UPDATE
      final StringBuffer newText = StringBuffer();
      if (newTextLength >= 4) {
        newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}-');
      }
      if (newTextLength >= 7) {
        newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
      }

      if (newTextLength > 9) {
        if (newTextLength >= usedSubstringIndex) {
          newText.write(newValue.text
              .substring(usedSubstringIndex, usedSubstringIndex + 4));
        }
      } else {
        if (newTextLength >= usedSubstringIndex) {
          newText.write(newValue.text.substring(usedSubstringIndex));
        }
      }
      final isLess =
          oldValue.text.replaceAll('-', '').length < newValue.text.length;
      if (isLess) {
        //UPDATE WITH FULL TEXT REMAIN
        final isSeprate =
            oldValue.text.substring(oldSelectionIndex, oldSelectionIndex + 1) ==
                '-';
        if (isSeprate) {
          return TextEditingValue(
            text: newText.toString(),
            selection: TextSelection.collapsed(offset: oldSelectionIndex + 2),
          );
        } else {
          return TextEditingValue(
            text: newText.toString(),
            selection: TextSelection.collapsed(offset: oldSelectionIndex + 1),
          );
        }
      } else {
        //UPDATE WITH TEXT IS DELETED (NEW VALUE WILL LESS THAN 10 CHAR)
        return TextEditingValue(
          text: newText.toString(),
          selection: TextSelection.collapsed(offset: oldSelectionIndex - 1),
        );
      }
    } else {
      //WRITE TEXT AT THE END
      final StringBuffer newText = StringBuffer();

      if (newTextLength >= 4) {
        newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}-');
        if (newValue.selection.end >= 3) selectionIndex++;
      }
      if (newTextLength >= 7) {
        newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
        if (newValue.selection.end >= 6) selectionIndex++;
      }

      if (newTextLength > 9) {
        if (newTextLength >= usedSubstringIndex) {
          newText.write(newValue.text
              .substring(usedSubstringIndex, usedSubstringIndex + 4));
        }
      } else {
        if (newTextLength >= usedSubstringIndex) {
          newText.write(newValue.text.substring(usedSubstringIndex));
        }
      }
      return TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
    }
  }
}
