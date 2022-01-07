library money_input_formatter;

import 'package:flutter/services.dart';
import 'package:function_tree/function_tree.dart';

class InvalidExpressionException implements Exception {}

extension NumberRounding on double {
  String truncatePrecision(int precision) {
    var res = toString();
    var decimal = res.indexOf('.');
    if (decimal == -1) {
      return res;
    }
    var decimalPosition = decimal + precision + 1;
    if (decimalPosition >= res.length) {
      return res + ("0" * (decimalPosition - res.length));
    }
    return res.substring(0, decimalPosition);
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  /// number of decimals allowed, defaults to 2
  final int precision;

  /// character separing the thousands, defaults to space
  final String thousandSeparator;

  /// caracter so separate the decimal digits, default to a period, a lot of language are using a comma though
  /// You can get the decimal from the local by calling numberFormatSymbols[language]?.DECIMAL_SEP
  final String decimalSeparator;

  MoneyInputFormatter({
    this.decimalSeparator = '.',
    this.thousandSeparator = ' ',
    this.precision = 2,
  }) {
    if (decimalSeparator == thousandSeparator) {
      throw Exception(
          "decimalSeparator cannot be the same as thousandSeparator");
    }
  }

  String applyMask(double value) {
    var fixedPrecision = value.toStringAsFixed(precision + 1);

    // we convert numbers like 0.213 into 0.23
    // this is due to the fact that there's a two digit limit
    // so if the user touches another digit, we expect to replace the last one
    if (fixedPrecision[fixedPrecision.length - 1] != '0') {
      var newVal = value.truncatePrecision(precision);
      value = double.parse(newVal.substring(0, newVal.length - 1) +
          fixedPrecision[fixedPrecision.length - 1]);
    }

    List<String?> textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList();

    textRepresentation.insert(precision, decimalSeparator);

    for (var i = precision + 4; true; i = i + 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      } else {
        break;
      }
    }

    var txt = textRepresentation.reversed.join('');
    return txt.replaceFirst("${decimalSeparator}00", '');
  }

  double numberValue(String val) {
    if (val == "") {
      return 0;
    }

    late num interpreted;
    try {
      interpreted = val
          .replaceAll(thousandSeparator, '')
          .replaceFirst(decimalSeparator, '.')
          .replaceFirst(',', '.')
          .interpret();
    } catch (e) {
      throw InvalidExpressionException();
    }

    return interpreted.toDouble();
  }

  TextEditingValue formatEditUpdateCalculate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text
        .replaceAll('--', '')
        .replaceAll('+-', '-')
        .replaceAll(' ', '');
    var difference = newText.length - oldValue.text.length;

    // no changes
    if (newText == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: newValue.selection.baseOffset + difference - 1),
      composing: TextRange.empty,
    );
  }

  bool containsCalculations(TextEditingValue value) {
    return value.text.contains('-') ||
        value.text.contains('+') ||
        value.text.contains('(') ||
        value.text.contains('*') ||
        value.text.contains('/') ||
        value.text.contains(')');
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == "0" || newValue.text == '') {
      return const TextEditingValue(
        text: "0",
        selection: TextSelection.collapsed(offset: 1),
        composing: TextRange.empty,
      );
    }

    if (containsCalculations(newValue)) {
      return formatEditUpdateCalculate(oldValue, newValue);
    }

    // too many separators
    if ('.'.allMatches(newValue.text).length > 1) {
      return oldValue;
    }

    // we deleted a space
    if (oldValue.text != newValue.text &&
        oldValue.text.replaceAll(' ', '') ==
            newValue.text.replaceAll(' ', '')) {
      var newVal =
          oldValue.text.substring(0, oldValue.selection.baseOffset - 2) +
              oldValue.text.substring(oldValue.selection.baseOffset - 1);
      var formattedVal = applyMask(numberValue(newVal));
      return TextEditingValue(
          text: formattedVal,
          selection: TextSelection.collapsed(
              offset: oldValue.selection.baseOffset - 2));
    }

    String masked = applyMask(numberValue(newValue.text));

    // no changes
    if (masked == newValue.text) {
      return newValue;
    }

    var spacesBeforeCursor = 0;
    var oldCursor = oldValue.selection.baseOffset;
    for (var i = 0; i < oldCursor; i++) {
      if (oldValue.text[i] == thousandSeparator) {
        spacesBeforeCursor++;
      }
    }
    oldCursor -= spacesBeforeCursor;
    spacesBeforeCursor = 0;

    var newCursor = newValue.selection.baseOffset;
    for (var i = 0; i < newCursor; i++) {
      if (newValue.text[i] == ' ') {
        spacesBeforeCursor++;
      }
    }
    newCursor -= spacesBeforeCursor;

    var spacesToAdd = 0;
    var _charCount = 0;
    for (var i = 0; i < masked.length; i++) {
      if (masked[i] == ' ') {
        spacesToAdd++;
      } else {
        _charCount++;
        if (_charCount == newCursor) {
          break;
        }
      }
    }

    var offset = newCursor + spacesToAdd;

    if (newValue.text.endsWith(decimalSeparator)) {
      masked += decimalSeparator;
    } else if (newValue.text.endsWith('${decimalSeparator}0') &&
        newCursor - oldCursor >= 0) {
      masked += '${decimalSeparator}0';
    }

    return TextEditingValue(
        text: masked,
        selection: TextSelection.collapsed(
            offset: offset > masked.length ? masked.length : offset));
  }
}
