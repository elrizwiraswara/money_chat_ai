import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/const/const.dart';
import '../../../../app/enum/category_type.dart';
import '../../../../app/enum/chat_role.dart';
import '../../../../app/enum/chat_type.dart';
import '../../../../app/enum/command_type.dart';
import '../../../../app/enum/input_source.dart';
import '../../../../app/services/firebase_storage/firebase_storage_service.dart';
import '../../../../app/services/open_ai/open_ai_service.dart';
import '../../../../app/utilities/command_parser.dart';
import '../../../../app/utilities/console_log.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../app/utilities/date_formatter.dart';
import '../../../../core/extensions/string_casing_extension.dart';
import '../../../../core/notifier/base_change_notifier.dart';
import '../../../../data/datasources/chat_datasource.dart';
import '../../../../data/models/chat_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../history/controller/history_controller.dart';
import '../../main/controller/main_controller.dart';
import '../../recap/controller/recap_controller.dart';

final chatController = ChangeNotifierProvider<ChatController>(
  (ref) => ChatController(ref),
);

class ChatController extends BaseChangeNotifier {
  late Ref ref;

  ChatController(this.ref);

  final _openAiService = OpenAIService();
  final _chatDatasource = ChatDatasource();

  final scrollController = ScrollController();
  final textController = TextEditingController();
  final focusNode = FocusNode();

  List<ChatModel> chats = [];

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.initialScrollOffset,
      duration: Duration(milliseconds: 200),
      curve: Curves.decelerate,
    );
  }

  Future<void> getChats() async {
    final user = ref.read(mainController).user;
    if (user == null) return;

    chats = await _chatDatasource.getAllChats(user.id);
    notifyListeners();

    _addWelcomeMessage();
  }

  Future<void> _saveChat(ChatModel chat) async {
    try {
      final user = ref.read(mainController).user;
      if (user == null) return;

      await _chatDatasource.createChat(user.id, chat);
    } catch (e) {
      cl(e);
    }
  }

  Future<void> _deleteChat(ChatModel chat) async {
    try {
      final user = ref.read(mainController).user;
      if (user == null) return;

      await _chatDatasource.deleteChat(user.id, chat);
    } catch (e) {
      cl(e);
    }
  }

  Future<void> clearChats() async {
    final user = ref.read(mainController).user;
    if (user == null) return;

    await _chatDatasource.clearChats(user.id);
    await getChats();
    await _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    if (chats.map((e) => e.type).contains(ChatType.welcomeMessage.name)) {
      return;
    }

    await addSystemChat(
      message: Constant.welcomeMessage,
      createdById: Constant.systemChatId,
      type: ChatType.welcomeMessage,
      isLoading: true,
    );
  }

  Future<void> makeLoading() async {
    if (chats.isEmpty) return;
    chats.first.isLoading = true;
    notifyListeners();
  }

  Future<void> addUserChat({String? message, XFile? file}) async {
    final user = ref.read(mainController).user;
    if (user == null) return;

    final chat = ChatModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      imageUrl: file?.path,
      createdById: user.id,
      role: ChatRole.user.name,
      type: ChatType.message.name,
      isLoading: file != null,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    chats.insert(0, chat);
    notifyListeners();

    final index = chats.indexWhere((e) => e.id == chat.id);

    if (file != null) {
      final imageUrl = await FirebaseStorageService().uploadChatImages(
        await file.readAsBytes(),
      );

      chats[index] = chat..imageUrl = imageUrl;
      chats[index] = chat..isLoading = false;
    }

    notifyListeners();

    await _saveChat(chat);
    await _handleChat(chat);

    _scrollDown();
  }

  Future<void> addSystemChat({
    required String message,
    required String createdById,
    String? errorMessage,
    ChatType? type,
    bool isLoading = false,
    TransactionModel? transaction,
  }) async {
    final chat = ChatModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      createdById: createdById,
      role: ChatRole.system.name,
      type: type?.name ?? ChatType.message.name,
      isLoading: isLoading,
      transaction: transaction,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    chats.insert(0, chat);
    notifyListeners();

    await _saveChat(chat);
    await _handleChat(chat);

    if (isLoading) {
      chats.first.isLoading = false;
      notifyListeners();
    }

    _scrollDown();
  }

  Future<void> addConfirmationChat({
    required TransactionModel transaction,
    String? imageUrl,
    String? ocrText,
  }) async {
    final items = transaction.items
        ?.map(
          (e) =>
              "${e.qty}x ${e.name} -${CurrencyFormatter.format(e.price ?? 0)}",
        )
        .toList();

    final subtotal =
        transaction.items?.fold<double>(
          0,
          (sum, item) => sum + ((item.price ?? 0) * (item.qty ?? 0)),
        ) ??
        0;

    final message =
        """
📜 ${transaction.type?.toTitleCase()} (${transaction.categoryId}) - ${transaction.merchant}${(items?.isNotEmpty ?? false) ? '\n${items?.join('\n')}\n' : ''}${transaction.discount != 0 ? '\nDiscount: ${CurrencyFormatter.format(transaction.discount ?? 0)}' : ''}${subtotal != 0 ? '\nSubtotal: ${CurrencyFormatter.format(subtotal)}' : ''}
Total: ${CurrencyFormatter.format(transaction.amount ?? 0)}
Date: ${DateFormatter.slashDateWithClock(transaction.date!)}""";

    final chat = ChatModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      imageUrl: imageUrl,
      ocrText: ocrText,
      createdById: Constant.systemChatId,
      role: ChatRole.system.name,
      type: ChatType.confirmation.name,
      isLoading: false,
      transaction: transaction,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    chats.insert(0, chat);
    notifyListeners();

    await _saveChat(chat);

    _scrollDown();
  }

  Future<void> addChangeCategoryChat({required TransactionModel trx}) async {
    final chat = ChatModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      content: 'Choose Category:',
      createdById: Constant.systemChatId,
      role: ChatRole.system.name,
      type: ChatType.changeCategory.name,
      isLoading: false,
      transaction: trx,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );

    chats.insert(0, chat);
    notifyListeners();

    await _saveChat(chat);

    _scrollDown();
  }

  Future<void> _removeNewestChat() async {
    if (chats.isEmpty) return;

    await _deleteChat(chats.first);
    await getChats();

    _scrollDown();
  }

  Future<void> _handleChat(ChatModel? chat) async {
    if (chat == null) return;

    final result = CommandParser.parseCommand(chat.content ?? '');

    if (result.noCommand) {
      if (chat.imageUrl != null) {
        await _handleChatImage(chat);
        return;
      }

      if (chat.content != null) {
        await _handleChatPrompt(chat);
        return;
      }

      return;
    }

    if (!result.isValid) {
      cl('Error: ${result.error}', type: LogType.error);
      return await addSystemChat(
        message: result.error ?? Constant.errorMessage,
        createdById: Constant.systemChatId,
      );
    }

    _handleCommand(result);
  }

  Future<void> _handleCommand(CommandResult result) async {
    switch (result.type) {
      case CommandType.addExpense:
        final amount = result.data!['amount'] as double;
        final description = result.data!['description'] as String;
        final category = result.data!['categoryId'] as String;
        await _addExpenses(amount, description, category);
        break;

      case CommandType.addIncome:
        final amount = result.data!['amount'] as double;
        final description = result.data!['description'] as String;
        await _addIncome(amount, description);
        break;

      case CommandType.edit:
        final id = result.data!['id'] as String;
        final field = result.data!['field'] as String;
        final value = result.data!['value'] as String;
        await _editTransaction(id, field, value);
        break;

      case CommandType.delete:
        final id = result.data!['id'] as String;
        await _deleteTransaction(id);
        break;

      case CommandType.recap:
        final month = result.data?['month'] as int?;
        final year = result.data?['year'] as int?;
        await _showRecap(month, year);
        break;

      case CommandType.help:
        await _showHelp();
        break;

      default:
        break;
    }
  }

  Future<void> _addExpenses(
    double amount,
    String description,
    String categoryId,
  ) async {
    cl('Adding expenses: $amount, $description, $categoryId');

    final mainCtrl = ref.read(mainController);
    final historyCtrl = ref.read(historyController);

    final trx = TransactionModel(
      amount: amount,
      merchant: description,
      categoryId: categoryId,
      categoryName: mainCtrl.categories
          .where((e) => e.id == categoryId)
          .firstOrNull
          ?.name,
    );

    await historyCtrl.createTransaction(
      trx: trx,
      type: CategoryType.expenses,
      source: InputSource.manual,
      showToast: false,
    );
  }

  Future<void> _addIncome(double amount, String description) async {
    cl('Adding income: $amount, $description');

    final mainCtrl = ref.read(mainController);
    final historyCtrl = ref.read(historyController);

    final categoryId = mainCtrl.incomeCategories.firstOrNull?.id;

    final trx = TransactionModel(
      amount: amount,
      merchant: description,
      categoryId: categoryId,
    );

    await historyCtrl.createTransaction(
      trx: trx,
      type: CategoryType.income,
      source: InputSource.manual,
      showToast: false,
    );
  }

  Future<void> _editTransaction(String id, String field, String value) async {
    cl('Editing transaction $id: $field = $value');

    final mainCtrl = ref.read(mainController);
    final historyCtrl = ref.read(historyController);

    final currTrx = await historyCtrl.getTransactionById(id.toUpperCase());

    if (currTrx == null) {
      return addSystemChat(
        message: '❌ Record with ID: $id not found!',
        createdById: Constant.systemChatId,
      );
    }

    if (field == 'amount') currTrx.amount = double.tryParse(value);
    if (field == 'desc') currTrx.merchant = value;

    if (field == 'cat') {
      final category = mainCtrl.categories.where((e) => e.id == value);

      if (category.isEmpty) {
        return addSystemChat(
          message: '❌ Record with ID: $value not found!',
          createdById: Constant.systemChatId,
        );
      } else {
        currTrx.categoryId = value;
        currTrx.categoryName = category.firstOrNull?.name;
      }
    }

    if (field == 'date') {
      final parts = value.split('-');
      final datePart = parts[0];

      // Extract date components (assuming DDMMYYYY format)
      final day = int.parse(datePart.substring(0, 2));
      final month = int.parse(datePart.substring(2, 4));
      final year = int.parse(datePart.substring(4, 8));

      int hour = 0;
      int minute = 0;

      // Parse time if provided
      if (parts.length > 1 && parts[1].isNotEmpty) {
        final timePart = parts[1];
        hour = int.parse(timePart.substring(0, 2));
        minute = int.parse(timePart.substring(2, 4));
      }

      currTrx.date = DateTime(year, month, day, hour, minute).toIso8601String();
    }

    await historyCtrl.updateTransaction(
      trx: currTrx,
      showToast: false,
    );
  }

  Future<void> _deleteTransaction(String id) async {
    cl('Deleting transaction: $id');

    final historyCtrl = ref.read(historyController);

    final currTrx = await historyCtrl.getTransactionById(id.toUpperCase());

    if (currTrx == null) {
      return addSystemChat(
        message: '❌ Record with ID: $id not found!',
        createdById: Constant.systemChatId,
      );
    }

    await historyCtrl.deleteTransaction(
      id: currTrx.id!,
      showToast: false,
    );
  }

  Future<void> _showRecap(int? month, int? year) async {
    cl('Showing recap for month: $month');

    final recapCtrl = ref.read(recapController);

    await recapCtrl.getShortRecap(month, year);
  }

  Future<void> _showHelp() async {
    await addSystemChat(
      message: Constant.helpMessage,
      createdById: Constant.systemChatId,
    );
  }

  Future<void> _handleChatPrompt(ChatModel chat) async {
    if (chat.createdById == Constant.systemChatId) {
      if (chat.type != ChatType.welcomeMessage.name) return;
    }

    final mainCtrl = ref.read(mainController);

    final categories = mainCtrl.categories.skip(1);
    final mappedCategory = categories.map((e) => e.toJson()).toList();
    final chatHistory = chats.reversed.toList();
    chatHistory.removeWhere((e) => e.id == chat.id);

    final isWelcome = chat.type == ChatType.welcomeMessage.name;
    final systemPrompt =
        "Available categories for classification:\n\n$mappedCategory\n\n${mainCtrl.config!.mainPrompt}";

    if (isWelcome) {
      await addSystemChat(
        message: systemPrompt,
        createdById: Constant.systemChatId,
        type: ChatType.initiator,
      );
    }

    final res = await _openAiService.sendPrompt(
      model: mainCtrl.config!.model,
      maxTokens: mainCtrl.config!.maxTokens,
      prompt: isWelcome ? systemPrompt : chat.content ?? '',
      role: ChatRole.user,
      userId: mainCtrl.user!.id,
      chatHistory: chatHistory,
    );

    cl('GPT Response:\n', json: res.toJson());

    final result = CommandParser.parseCommand(res.content ?? '');

    if (result.isValid && !result.noCommand) {
      return _handleCommand(result);
    }

    await addSystemChat(
      message: res.content ?? res.errorMessage ?? Constant.errorMessage,
      createdById: Constant.systemChatId,
      type: chat.type == ChatType.welcomeMessage.name
          ? ChatType.welcomeMessageResponse
          : ChatType.message,
    );
  }

  Future<void> _handleChatImage(ChatModel? chat) async {
    if (chat?.imageUrl == null) return;

    final mainCtrl = ref.read(mainController);

    await addSystemChat(
      message: '🧐 Analyzing image...',
      createdById: Constant.systemChatId,
    );

    await makeLoading();

    final imageRes = await _openAiService.sendPrompt(
      model: mainCtrl.config!.model,
      maxTokens: mainCtrl.config!.maxTokens,
      prompt: mainCtrl.config!.extractImagePrompt,
      role: ChatRole.user,
      userId: mainCtrl.user!.id,
      imageUrl: chat!.imageUrl!,
    );

    cl('GPT Response:\n', json: imageRes.toJson());

    if (!imageRes.isSuccess) {
      await _removeNewestChat();
      await addSystemChat(
        message: imageRes.errorMessage ?? Constant.errorMessage,
        createdById: Constant.systemChatId,
      );
      return;
    }

    if (imageRes.content == 'invalid receipt') {
      await _removeNewestChat();
      await addSystemChat(
        message: Constant.invalidReceiptMessage,
        createdById: Constant.systemChatId,
      );
      return;
    }

    final categories = ref.read(mainController).categories.skip(1);
    final mappedCategory = categories.map((e) => e.toJson()).toList();

    final res = await _openAiService.sendPrompt(
      model: mainCtrl.config!.model,
      maxTokens: mainCtrl.config!.maxTokens,
      prompt:
          'Available categories for classification:\n\n$mappedCategory\n\n${mainCtrl.config!.extractReceiptPrompt}\n\n${imageRes.content}',
      role: ChatRole.user,
      userId: mainCtrl.user!.id,
    );

    cl('GPT Response:\n', json: res.toJson());

    if (!res.isSuccess) {
      await _removeNewestChat();
      await addSystemChat(
        message: res.errorMessage ?? Constant.errorMessage,
        createdById: Constant.systemChatId,
      );
      return;
    }

    String cleanJson = res.content!
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    cl(cleanJson);

    final transaction = TransactionModel.fromJson(jsonDecode(cleanJson));
    transaction.type = CategoryType.expenses.name;
    transaction.categoryName = mainCtrl.categories
        .where((e) => e.id == transaction.categoryId)
        .firstOrNull
        ?.name;

    await _removeNewestChat();

    await addConfirmationChat(
      transaction: transaction,
      imageUrl: chat.imageUrl,
      ocrText: imageRes.content,
    );
  }
}
