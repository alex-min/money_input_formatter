# MoneyInputFormatter

A flutter package to format currencies in inputs.

Demo:

![Video demo of typing numbers which are formatted](https://alex-min.fr/videos/money_input_formatter.gif)

## Features

- The decimal & thousands separators can be configured, the input can show "1 333,34" in French and "1 333.34" in English. 
- Automatically deletes .00 to make numbers more readable
- Handles deleting of spaces & cursor position
- Battle tested on production & extensive tests are included in the repo

## Usage

Just use it as an inputFormater on any input and it will format the data accordingly.

```dart
 TextFormField(
     inputFormatters: [MoneyInputFormatter()],
     keyboardType: TextInputType.number
  )
```

This package also provides a controller associated with it to get back the value as a number.

```dart
import 'package:flutter/material.dart';
import 'package:money_input_formatter/money_input_controller.dart';
import 'package:money_input_formatter/money_input_formatter.dart';

class Widget extends StatefulWidget {
  @override
  State<Widget> createState() => _Widget();
}

class _Widget extends State<Widget> {
  final controller = MoneyInputController();
  double value = 0;

 @override
  Widget build(BuildContext context) {
    return TextFormField(
    textAlign: TextAlign.end,
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: (_) => setState(() => value = controller.numberValue) // convert to a number
    inputFormatters: [MoneyInputFormatter()],
    )
  }
}
```
