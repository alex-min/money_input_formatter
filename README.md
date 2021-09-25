A flutter package to format currencies in inputs.

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
