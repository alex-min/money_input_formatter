import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_input_formatter/money_input_formatter.dart';

void main() async {
  test('truncate precision', () {
    expect(55.449.truncatePrecision(2), '55.44');
    expect(55.4.truncatePrecision(2), '55.40');
    expect(55.4.truncatePrecision(5), '55.40000');
  });

  test('no value should nothing with the cursor at the end', () {
    var res = MoneyInputFormatter()
        .formatEditUpdate(const TextEditingValue(), const TextEditingValue());
    expect(res.text, '');
    expect(res.selection.baseOffset, 0, reason: 'cursor is at the end');
    expect(res.selection.extentOffset, 0, reason: 'no selection');
  });

  test('deleting zero works', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(text: "0"), const TextEditingValue());
    expect(res.text, '');
    expect(res.selection.baseOffset, 0, reason: 'cursor is at the end');
    expect(res.selection.extentOffset, 0, reason: 'no selection');
  });

  test('deleting a space reformats the input: 123 |456 => 12| 456', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "123 456",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)),
        const TextEditingValue(
            text: "123456",
            selection: TextSelection(baseOffset: 3, extentOffset: 3)));
    expect(res.text, '12 456');
    expect(res.selection.baseOffset, 2, reason: 'cursor is after the two');
    expect(res.selection.extentOffset, 2, reason: 'no selection');
  });

  test('three digits are converted to two digits (1.213 => 1.23)', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1.21",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)),
        const TextEditingValue(
            text: "1.213",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)));
    expect(res.text, '1.23');
    expect(res.selection.baseOffset, 4, reason: 'cursor is still at the end');
    expect(res.selection.extentOffset, 4, reason: 'no selection');
  });

  test('does not round up after three digits (1.299 => 1.29)', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1.29",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)),
        const TextEditingValue(
            text: "1.299",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)));
    expect(res.text, '1.29');
    expect(res.selection.baseOffset, 4, reason: 'cursor is still at the end');
    expect(res.selection.extentOffset, 4, reason: 'no selection');
  });

  test('works for comma insertion', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)),
        const TextEditingValue(
            text: "1.",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)));

    expect(res.text, '1.');
    expect(res.selection.baseOffset, 2, reason: 'cursor is still at the end');
    expect(res.selection.extentOffset, 2, reason: 'no selection');
  });

  test('works for digit after comma insertion', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1.",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)),
        const TextEditingValue(
            text: "1.0",
            selection: TextSelection(baseOffset: 3, extentOffset: 3)));

    expect(res.text, '1.0');
    expect(res.selection.baseOffset, 3, reason: 'cursor is still at the end');
    expect(res.selection.extentOffset, 3, reason: 'no selection');
  });

  test('formats the text and keeps the cursor', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "123456",
            selection: TextSelection(baseOffset: 3, extentOffset: 3)),
        const TextEditingValue(
            text: "1239456",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)));

    expect(res.text, '1 239 456');
    expect(res.selection.baseOffset, 5,
        reason: 'cursor moved due to adding a space when formatting');
    expect(res.selection.extentOffset, 5, reason: 'no selection');
  });

  test('works with i18n', () {
    var text = MoneyInputFormatter(decimalSeparator: ',');
    var res = text.formatEditUpdate(
        const TextEditingValue(
            text: "11114,32",
            selection: TextSelection(baseOffset: 8, extentOffset: 8)),
        const TextEditingValue(
            text: "11114,323",
            selection: TextSelection(baseOffset: 9, extentOffset: 9)));

    expect(res.text, '11 114,33');
    expect(res.selection.baseOffset, 9);
    expect(res.selection.extentOffset, 9);
    expect(text.numberValue(res.text), 11114.33);
  });

  test('deleting caracter works', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "3.0",
            selection: TextSelection(baseOffset: 3, extentOffset: 3)),
        const TextEditingValue(
            text: "3.",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)));
    expect(res.text, "3.");
    expect(res.selection.baseOffset, 2);
    expect(res.selection.extentOffset, 2);
  });

  test('formatting after caracter deletion works', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "123 456.21",
            selection: TextSelection(baseOffset: 6, extentOffset: 6)),
        const TextEditingValue(
            text: "123 46.21",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)));
    expect(res.text, '12 346.21');
    expect(res.selection.baseOffset, 5);
    expect(res.selection.extentOffset, 5);
  });

  test('deleting caracter removes useless comma 0', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "58.09",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)),
        const TextEditingValue(
            text: "58.0",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)));
    expect(res.text, '58');
    expect(res.selection.baseOffset, 2);
    expect(res.selection.extentOffset, 2);
  });

  test('inserting multiple chars at once', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "58.09",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)),
        const TextEditingValue(
            text: "50008.09",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)));
    expect(res.text, "50 008.09");
    expect(res.selection.baseOffset, 5);
    expect(res.selection.extentOffset, 5);
  });

  test('works for digit after comma insertion', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "0",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)),
        const TextEditingValue(
            text: "0.",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)));

    expect(res.text, '0.');
    expect(res.selection.baseOffset, 2, reason: 'cursor is still at the end');
    expect(res.selection.extentOffset, 2, reason: 'no selection');
  });

  // negative tests
  test('inserts negative ', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "5",
            selection: TextSelection(baseOffset: 0, extentOffset: 0)),
        const TextEditingValue(
            text: "-5",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)));

    expect(res.text, '-5');
    expect(res.selection.baseOffset, 1,
        reason: 'cursor next to negative sign as normal');
    expect(res.selection.extentOffset, 1, reason: 'no selection');
  });

  test('deletes double negative', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "-5",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)),
        const TextEditingValue(
            text: "--5",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)));
    expect(res.text, '5');
    expect(res.selection.baseOffset, 0);
  });

  test('deletes useless plus', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "-5",
            selection: TextSelection(baseOffset: 1, extentOffset: 1)),
        const TextEditingValue(
            text: "+-5",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)));
    expect(res.text, '-5');
    expect(res.selection.baseOffset, 1);
  });

  test('inserts negative', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1234",
            selection: TextSelection(baseOffset: 2, extentOffset: 2)),
        const TextEditingValue(
            text: "12-34",
            selection: TextSelection(baseOffset: 3, extentOffset: 3)));

    expect(res.text, '12-34', reason: 'allows the negative sign');
    expect(res.selection.baseOffset, 3, reason: 'cursor works as normal');
    expect(res.selection.extentOffset, 3, reason: 'no selection');
  });

  test('removes all spaces from calculations', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1 234",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)),
        const TextEditingValue(
            text: "1 234-",
            selection: TextSelection(baseOffset: 6, extentOffset: 6)));

    expect(res.text, '1234-', reason: 'no spaces for calculations');
    expect(res.selection.baseOffset, 5, reason: 'cursor should be at the end');
  });

  test('inserts a plus sign when typing', () {
    var res = MoneyInputFormatter().formatEditUpdate(
        const TextEditingValue(
            text: "1 234",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)),
        const TextEditingValue(
            text: "1 234+",
            selection: TextSelection(baseOffset: 6, extentOffset: 6)));

    expect(res.text, '1234+',
        reason: 'plus is inserted normally and spaces deleted');
    expect(res.selection.baseOffset, 5, reason: 'cursor should be at the end');
  });

  test('adding a second digit separator', () {
    var text = MoneyInputFormatter(decimalSeparator: ',');
    var res = text.formatEditUpdate(
        const TextEditingValue(
            text: "11,1",
            selection: TextSelection(baseOffset: 4, extentOffset: 4)),
        const TextEditingValue(
            text: "11,1,",
            selection: TextSelection(baseOffset: 5, extentOffset: 5)));

    expect(res.text, '11,1', reason: 'did not change');
    expect(res.selection.baseOffset, 4, reason: 'cursor should be at the end');
  });
}
