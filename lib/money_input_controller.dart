library money_input_formatter;

import 'package:flutter/cupertino.dart';
import 'package:money_input_formatter/money_input_formatter.dart';

class MoneyInputController extends TextEditingController {
  /// number of decimals allowed, defaults to 2
  final int precision;

  /// character separing the thousands, defaults to space
  final String thousandSeparator;

  /// caracter so separate the decimal digits, default to a period, a lot of language are using a comma though
  /// You can get the decimal from the local by calling numberFormatSymbols[language]?.DECIMAL_SEP
  final String decimalSeparator;

  MoneyInputController({
    this.decimalSeparator = '.',
    this.thousandSeparator = ' ',
    this.precision = 2,
  }) : super();

  MoneyInputFormatter get _formatter {
    return MoneyInputFormatter(
      decimalSeparator: decimalSeparator,
      thousandSeparator: thousandSeparator,
      precision: precision,
    );
  }

  // set the value of the input formatted properly
  set numberValue(double value) {
    text = _formatter.applyMask(value);
  }

  /// get the actual input value as a double
  double get numberValue => _formatter.numberValue(text);
}
