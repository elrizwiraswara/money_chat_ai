import 'package:app_image/app_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/const/const.dart';
import '../../../app/enum/category_type.dart';
import '../../../app/enum/chat_role.dart';
import '../../../app/enum/chat_type.dart';
import '../../../app/enum/command_type.dart';
import '../../../app/enum/input_source.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../app/utilities/console_log.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/chat_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_image_picker_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import '../history/controller/history_controller.dart';
import '../main/controller/main_controller.dart';
import 'controller/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatController).getChats();
    });
    super.initState();
  }

  void onTapAddImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile == null) return;

    final controller = ref.read(chatController);

    controller.addUserChat(file: pickedFile);
  }

  void onSubmitted() {
    final controller = ref.read(chatController);
    if (controller.textController.text.isEmpty) return;

    controller.addUserChat(message: controller.textController.text);

    FocusScope.of(context).unfocus();
    controller.textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          chatBody(),
          textFieldBody(),
        ],
      ),
    );
  }

  Widget chatBody() {
    final scrollController = ref.read(chatController).scrollController;

    final chats = ref
        .watch(chatController)
        .chats
        .where((e) => e.type != ChatType.initiator.name)
        .where((e) => e.type != ChatType.welcomeMessageResponse.name)
        .toList();

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        itemCount: chats.length,
        reverse: true,
        dragStartBehavior: DragStartBehavior.down,
        padding: EdgeInsets.fromLTRB(
          AppSizes.padding,
          AppSizes.padding,
          AppSizes.padding,
          AppSizes.padding * 9,
        ),
        itemBuilder: (context, i) {
          return chatBubble(i == 0, chats[i]);
        },
      ),
    );
  }

  Widget chatBubble(bool isNewest, ChatModel chat) {
    final isDebug = ref.watch(mainController).isDebug;

    return Row(
      mainAxisAlignment: chat.createdById == Constant.systemChatId
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(bottom: AppSizes.margin),
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.padding,
              horizontal: chat.imageUrl != null
                  ? AppSizes.padding
                  : AppSizes.padding * 1.2,
            ),
            decoration: BoxDecoration(
              color: AppColors.blackLv5,
              borderRadius: BorderRadius.circular(AppSizes.radius * 2),
            ),
            child: !chat.isLoading || chat.content != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chat.role == ChatRole.user.name &&
                          chat.imageUrl != null)
                        AppImage(
                          image: chat.imageUrl,
                          width: 250,
                          height: 250,
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          enableFullScreenView: true,
                          context: AppRoutes.rootNavigatorKey.currentContext,
                          fadeInDuration: Duration.zero,
                        ),
                      if (chat.content != null &&
                          chat.role == ChatRole.user.name &&
                          chat.imageUrl != null)
                        SizedBox(height: AppSizes.padding),
                      if (chat.content != null)
                        SelectableText(
                          chat.content!,
                          style: AppTextStyle.semibold(size: 11),
                        ),
                      if (isDebug)
                        SelectableText(
                          "\nChat ID:\n${chat.id}\n\nChat Role:\n${chat.role}${chat.imageUrl != null ? '\n\nImage URL:\n${chat.imageUrl}' : ''}${chat.ocrText != null ? '\n\nRAW OCR Text:\n${chat.ocrText}' : ''}${chat.transaction != null ? '\n\nParsed JSON:\n${jsonPrettier(chat.transaction!.toDebugJson())}' : ''}",
                          style: AppTextStyle.regular(
                            size: 10,
                            color: AppColors.blackLv2,
                          ),
                        ),
                      if ((chat.type != ChatType.message.name &&
                              chat.type != ChatType.welcomeMessage.name) &&
                          isNewest)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSizes.padding),
                          child: Wrap(
                            spacing: AppSizes.padding / 2,
                            runSpacing: AppSizes.padding / 2,
                            children: messageButtons(chat),
                          ),
                        ),
                    ],
                  )
                : SizedBox(
                    width: 250,
                    height: 250,
                    child: AppProgressIndicator().small(),
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> messageButtons(ChatModel chat) {
    if (chat.type == ChatType.confirmation.name) {
      return [
        saveButton(chat),
        changeCategoryButton(chat),
        reCaptureButton(chat),
      ];
    }

    if (chat.type == ChatType.changeCategory.name) {
      final categories = ref.read(mainController).expensesCategories;

      return List.generate(
        categories.length,
        (i) => categoryButton(categories[i], chat),
      );
    }

    return [];
  }

  Widget saveButton(ChatModel chat) {
    return AppButton(
      enabled: !chat.isLoading,
      text: '✅ Save',
      fontSize: 12,
      buttonColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius * 2),
      borderColor: AppColors.blackLv1,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.padding / 4,
      ),
      alignment: null,
      onTap: () async {
        if (chat.transaction == null) return;
        final chatCtrl = ref.read(chatController);
        final historyCtrl = ref.read(historyController);
        await chatCtrl.makeLoading();
        await historyCtrl.createTransaction(
          trx: chat.transaction!,
          type: CategoryType.fromValue(chat.transaction!.type),
          source: InputSource.auto,
          showToast: false,
        );
      },
    );
  }

  Widget changeCategoryButton(ChatModel chat) {
    return AppButton(
      enabled: !chat.isLoading,
      text: '🖊️ Change Category',
      fontSize: 12,
      buttonColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius * 2),
      borderColor: AppColors.blackLv1,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.padding / 4,
      ),
      alignment: null,
      onTap: () {
        final controller = ref.read(chatController);
        controller.addSystemChat(
          message: 'Choose Category:',
          createdById: Constant.systemChatId,
          type: ChatType.changeCategory,
          transaction: chat.transaction,
        );
      },
    );
  }

  Widget reCaptureButton(ChatModel chat) {
    return AppButton(
      enabled: !chat.isLoading,
      text: '🔄 Retake Photo',
      fontSize: 12,
      buttonColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius * 2),
      borderColor: AppColors.blackLv1,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.padding / 4,
      ),
      alignment: null,
      onTap: () async {
        final XFile? file = await AppDialog.show(
          child: AppImagePickerDialog(),
        );

        if (file == null) return;

        final controller = ref.read(chatController);
        controller.addUserChat(file: file);
      },
    );
  }

  Widget categoryButton(CategoryModel category, ChatModel chat) {
    return AppButton(
      enabled: !chat.isLoading,
      text: '${category.name}',
      fontSize: 12,
      buttonColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius * 2),
      borderColor: AppColors.blackLv1,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.padding / 4,
      ),
      alignment: null,
      onTap: () {
        cl(chat.transaction?.toJson());
        if (chat.transaction == null) return;
        final controller = ref.read(chatController);
        chat.content = '${chat.content}\n${category.name} (${category.id})';
        chat.transaction!.categoryId = category.id;
        controller.addConfirmationChat(transaction: chat.transaction!);
      },
    );
  }

  Widget textFieldBody() {
    final textController = ref.read(chatController).textController;
    final focusNode = ref.read(chatController).focusNode;

    final newestChat = ref.watch(chatController).chats.firstOrNull;
    final disabled = newestChat?.isLoading == true;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.padding),
      padding: EdgeInsets.only(bottom: AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius * 2),
          topRight: Radius.circular(AppSizes.radius * 2),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            width: 1,
            color: disabled ? AppColors.blackLv4 : AppColors.blackLv1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius * 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSizes.padding / 2),
            AppTextField(
              controller: textController,
              focusNode: focusNode,
              hintText: 'Type here...',
              contentPadding: EdgeInsets.zero,
              enabled: !disabled,
              onEditingComplete: disabled
                  ? null
                  : () {
                      onSubmitted();
                    },
            ),
            SizedBox(height: AppSizes.padding * 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: AppSizes.padding / 2,
                  children: [
                    IgnorePointer(
                      ignoring: disabled,
                      child: Opacity(
                        opacity: disabled ? 0.3 : 1.0,
                        child: commandButton(),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: disabled,
                      child: Opacity(
                        opacity: disabled ? 0.3 : 1.0,
                        child: AppIconButton(
                          icon: Icons.camera_alt_outlined,
                          iconSize: 18,
                          onTap: () {
                            if (disabled) return;
                            onTapAddImage(ImageSource.camera);
                          },
                        ),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: disabled,
                      child: Opacity(
                        opacity: disabled ? 0.3 : 1.0,
                        child: AppIconButton(
                          icon: Icons.add_photo_alternate_outlined,
                          iconSize: 18,
                          onTap: () {
                            if (disabled) return;
                            onTapAddImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  ignoring: disabled,
                  child: Opacity(
                    opacity: disabled ? 0.3 : 1.0,
                    child: AppIconButton(
                      icon: Icons.arrow_upward,
                      iconSize: 18,
                      onTap: () {
                        if (disabled) return;
                        onSubmitted();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget commandButton() {
    final commands = CommandType.getValidCommands();
    final texController = ref.read(chatController).textController;

    return PopupMenuButton(
      color: Colors.white,
      menuPadding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      offset: Offset(0, -250),
      popUpAnimationStyle: AnimationStyle.noAnimation,
      splashRadius: 0,
      itemBuilder: (context) {
        return List.generate(commands.length, (i) {
          return PopupMenuItem(
            height: 40,
            child: Text(
              commands[i].command,
              style: AppTextStyle.semibold(size: 12),
            ),
            onTap: () {
              texController.text = '${commands[i].command} ';

              if (commands[i].command == CommandType.help.command) {
                onSubmitted();
                return;
              }

              ref.read(chatController).focusNode.requestFocus();

              Future.delayed(Duration(milliseconds: 100), () {
                texController.selection = TextSelection(
                  baseOffset: texController.text.length,
                  extentOffset: texController.text.length,
                );
              });
            },
          );
        });
      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.blackLv6,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1,
            color: AppColors.blackLv1,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: AppColors.blackLv1,
        ),
      ),
    );
  }
}
