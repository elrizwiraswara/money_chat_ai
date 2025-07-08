import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/models/category_model.dart';
import '../enum/category_type.dart';

class Constant {
  static const String systemChatId = 'system';

  static String googleSignInClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';
  static String cloudFunctionBaseUrl = dotenv.env['CLOUD_FUNCTIONS_URL'] ?? '';

  static const String githubRepo =
      'https://github.com/elrizwiraswara/money_chat_ai';

  static const String welcomeMessage =
      "👋 Welcome! Take receipt photo or type /help for showing available commands.";

  static const String errorMessage =
      "Somehing went wrong, please try again later.";

  static const String invalidReceiptMessage = """
Oops! It looks like the receipt photo is unclear or not a shopping receipt.
Try taking the photo again with a better angle! 📸""";

  static const String helpMessage = """
Here are the text commands you can use:

/addex <amount> <description> <category-id>
  → Add a manual expense
     Example: /addex 45000 coffee food

/addin <amount> <description>
  → Add a manual income
     Example: /addin 150000 freelance

/edit <id> <field> <value>
  → Edit a transaction (amount | desc | cat | date)
     Example: /edit ex000001 amount 30000

/del <id>
  → Delete a transaction
     Example: /del ex000001

/recap <month> <year>
  → Quick recap of Income / Expenses / Balance
     Example: /recap 01 2025

/help
  → Show this help menu""";

  static List<CategoryModel> categorySeed = [
    CategoryModel(
      id: 'food',
      name: '🍔 Food & Beverage',
      type: CategoryType.expenses.name,
      color: Color(0xFFFFAB91).toARGB32(),
    ),
    CategoryModel(
      id: 'trans',
      name: '🚗 Transport',
      type: CategoryType.expenses.name,
      color: Color(0xFFEF9A9A).toARGB32(),
    ),
    CategoryModel(
      id: 'bill',
      name: '💡 Bills/Utilities',
      type: CategoryType.expenses.name,
      color: Color(0xFF80CBC4).toARGB32(),
    ),
    CategoryModel(
      id: 'shop',
      name: '🛍️ Shopping',
      type: CategoryType.expenses.name,
      color: Color(0xFFA5D6A7).toARGB32(),
    ),
    CategoryModel(
      id: 'enter',
      name: '🎮 Entertainment',
      type: CategoryType.expenses.name,
      color: Color(0xFF9FA8DA).toARGB32(),
    ),
    CategoryModel(
      id: 'edu',
      name: '🎓 Education',
      type: CategoryType.expenses.name,
      color: Color(0xFFB39DDB).toARGB32(),
    ),
    CategoryModel(
      id: 'other',
      name: '📦 Others',
      type: CategoryType.expenses.name,
      color: Color(0xFFFFCC02).toARGB32(),
    ),
    CategoryModel(
      id: 'mix',
      name: '⚡ Mixed',
      type: CategoryType.expenses.name,
      color: Color(0xFFFFE082).toARGB32(),
    ),
    CategoryModel(
      id: 'income',
      name: '💰 Income',
      type: CategoryType.income.name,
      color: Color(0xFFFFF59D).toARGB32(),
    ),
  ];
}
