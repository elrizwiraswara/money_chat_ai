import '../enum/command_type.dart';

class CommandParser {
  static CommandResult parseCommand(String message) {
    final trimmed = message.trim();

    if (!trimmed.startsWith('/')) {
      return CommandResult(
        type: CommandType.noCommand,
        error: 'Not a command',
      );
    }

    final parts = trimmed.split(' ');
    final commandType = CommandType.fromString(parts[0]);

    switch (commandType) {
      case CommandType.addExpense:
        return _parseAddExpense(parts);
      case CommandType.addIncome:
        return _parseAddIncome(parts);
      case CommandType.edit:
        return _parseEdit(parts);
      case CommandType.delete:
        return _parseDelete(parts);
      case CommandType.recap:
        return _parseRecap(parts);
      case CommandType.help:
        return CommandResult(type: CommandType.help);
      case CommandType.invalid:
        return CommandResult(
          type: CommandType.invalid,
          error: 'Unknown command: ${parts[0]}',
        );
      case CommandType.noCommand:
        return CommandResult(
          type: CommandType.noCommand,
          error: 'Not a command',
        );
    }
  }

  static CommandResult _parseAddExpense(List<String> parts) {
    // /addex <amount> <description> <category-id>
    if (parts.length < 4) {
      return CommandResult(
        type: CommandType.invalid,
        error:
            '❌ Wrong command format!\n👉 /addex <amount> <description> <category-id>\n     Example: /addex 10000 burger food',
      );
    }

    final amount = double.tryParse(parts[1]);
    if (amount == null) {
      return CommandResult(
        type: CommandType.invalid,
        error: '❌ Invalid amount: ${parts[1]}',
      );
    }

    final description = parts.sublist(2, parts.length - 1).join(' ');
    final categoryId = parts.last;

    if (categoryId.isEmpty) {
      return CommandResult(
        type: CommandType.invalid,
        error: '❌ Invalid category ID: $categoryId',
      );
    }

    return CommandResult(
      type: CommandType.addExpense,
      data: {
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
      },
    );
  }

  static CommandResult _parseAddIncome(List<String> parts) {
    // /addin <amount> <description>
    if (parts.length < 3) {
      return CommandResult(
        type: CommandType.invalid,
        error:
            '❌ Wrong command format!\n👉 /addin <amount> <description>\n     Example: /addin 10000 freelance',
      );
    }

    final amount = double.tryParse(parts[1]);
    if (amount == null) {
      return CommandResult(
        type: CommandType.invalid,
        error: '❌ Invalid amount: ${parts[1]}',
      );
    }

    final description = parts.sublist(2).join(' ');

    return CommandResult(
      type: CommandType.addIncome,
      data: {
        'amount': amount,
        'description': description,
      },
    );
  }

  static CommandResult _parseEdit(List<String> parts) {
    // /edit <id> <field> <value>
    if (parts.length < 4) {
      return CommandResult(
        type: CommandType.invalid,
        error:
            '❌ Wrong command format!\n👉 /edit <id> <field> <value>\n     Example: /edit ex000001 amount 30000\n\nfield:\n- amount: amount\n- desc: description/merchant\n- cat: category-id, e.g. food\n- date: date (DDMMYY-HHMM), e.g. 010125-0110',
      );
    }

    final id = parts[1];
    final field = parts[2].toLowerCase();
    final allowedFields = ['amount', 'desc', 'cat', 'date'];

    if (!allowedFields.contains(field)) {
      return CommandResult(
        type: CommandType.invalid,
        error: '❌ Invalid field. Use: amount, desc, cat, or date',
      );
    }

    final value = parts.sublist(3).join(' ');

    // Validate value based on field type
    if (field == 'amount') {
      final amount = double.tryParse(value);
      if (amount == null) {
        return CommandResult(
          type: CommandType.invalid,
          error: '❌ Invalid amount: $value',
        );
      }
    }

    return CommandResult(
      type: CommandType.edit,
      data: {
        'id': id,
        'field': field,
        'value': value,
      },
    );
  }

  static CommandResult _parseDelete(List<String> parts) {
    // /del <id>
    if (parts.length != 2) {
      return CommandResult(
        type: CommandType.invalid,
        error:
            '❌ Wrong command format!\n👉 /del <id>\n     Example: /del ex000001',
      );
    }

    return CommandResult(
      type: CommandType.delete,
      data: {
        'id': parts[1],
      },
    );
  }

  static CommandResult _parseRecap(List<String> parts) {
    if (parts.length > 3) {
      return CommandResult(
        type: CommandType.invalid,
        error:
            '❌ Wrong command format!\n👉 /recap <month> <year>\n     Example: /recap 01 2024',
      );
    }

    int? month;
    int? year;

    if (parts.length >= 2) {
      final firstParam = parts[1];

      // Check if first parameter is a year (4 digits) or month (1-2 digits)
      final firstParamInt = int.tryParse(firstParam);
      if (firstParamInt == null) {
        return CommandResult(
          type: CommandType.invalid,
          error: '❌ Invalid parameter: $firstParam',
        );
      }

      if (firstParam.length == 4) {
        // First parameter is year
        year = firstParamInt;
        if (year < 1900 || year > 2100) {
          return CommandResult(
            type: CommandType.invalid,
            error: '❌ Invalid year: $year',
          );
        }
      } else {
        // First parameter is month
        month = firstParamInt;
        if (month < 1 || month > 12) {
          return CommandResult(
            type: CommandType.invalid,
            error: '❌ Invalid month. Use 1-12',
          );
        }
      }
    }

    if (parts.length == 3) {
      final secondParam = parts[2];
      final secondParamInt = int.tryParse(secondParam);

      if (secondParamInt == null) {
        return CommandResult(
          type: CommandType.invalid,
          error: '❌ Invalid parameter: $secondParam',
        );
      }

      if (month != null) {
        // Second parameter should be year
        year = secondParamInt;
        if (year < 1900 || year > 2100) {
          return CommandResult(
            type: CommandType.invalid,
            error: '❌ Invalid year: $year',
          );
        }
      } else {
        // First param was year, second param should be month
        month = secondParamInt;
        if (month < 1 || month > 12) {
          return CommandResult(
            type: CommandType.invalid,
            error: '❌ Invalid month. Use 1-12',
          );
        }
      }
    }

    return CommandResult(
      type: CommandType.recap,
      data: {
        'month': month,
        'year': year,
      },
    );
  }
}

class CommandResult {
  final CommandType type;
  final Map<String, dynamic>? data;
  final String? error;

  CommandResult({
    required this.type,
    this.data,
    this.error,
  });

  bool get isValid => type != CommandType.invalid;
  bool get noCommand => type == CommandType.noCommand;
}
