import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assets/app_assets.dart';
import '../../../app/const/const.dart';
import '../../../app/services/auth/auth_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../app/utilities/open_link.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_toast.dart';
import '../chat/controller/chat_controller.dart';
import '../error_handler_screen.dart';
import '../root_screen.dart';
import 'components/about_app_dialog.dart';
import 'components/edit_profile_dialog.dart';
import 'components/profile_dialog.dart';
import 'controller/main_controller.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _calculateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/chat')) {
      return 0;
    }

    if (location.startsWith('/history')) {
      return 1;
    }

    if (location.startsWith('/recap')) {
      return 2;
    }

    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/chat');
      case 1:
        GoRouter.of(context).go('/history');
      case 2:
        GoRouter.of(context).go('/recap');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final isLoaded = ref.watch(mainController).isLoaded;
    final config = ref.watch(mainController).config;
    final user = ref.watch(mainController).user;

    if (!isLoaded) {
      return const RootScreen();
    }

    if (isLoaded && config == null && user == null) {
      return const ErrorScreen();
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppSizes.maxWidth),
          child: Scaffold(
            backgroundColor: AppColors.blackLv4,
            appBar: appBar(),
            body: widget.child,
            bottomNavigationBar: bottomNavBar(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: Size(AppSizes.maxWidth, 100),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          AppSizes.padding / 4,
          AppSizes.padding / 4,
          AppSizes.padding / 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.blackLv6,
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppColors.blackLv5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onLongPress: () {
                final mainCtrl = ref.read(mainController);
                mainCtrl.isDebug = !mainCtrl.isDebug;
                ref.read(chatController).notifyListeners();
                AppToast.show(
                  message:
                      'Debug mode ${mainCtrl.isDebug ? 'activated' : 'deactivated'}',
                );
              },
              child: Row(
                children: [
                  AppImage(
                    image: AppAssets.logo,
                    height: 24,
                  ),
                  SizedBox(width: AppSizes.margin / 2),
                  Text(
                    'MoneyChat.ai',
                    style: AppTextStyle.bold(size: 14),
                  ),
                ],
              ),
            ),
            popUpMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget popUpMenuButton() {
    final user = ref.watch(mainController).user;
    final version = ref.watch(mainController).appVersion;

    return PopupMenuButton(
      color: Colors.white,
      menuPadding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      iconSize: 16,
      offset: Offset(0, 42),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            height: 56,
            child: Row(
              children: [
                AppImage(
                  image: user?.photoURL,
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(100),
                  backgroundColor: AppColors.blackLv5,
                  errorWidget: Icon(
                    Icons.person_2_outlined,
                    color: AppColors.blackLv3,
                  ),
                ),
                SizedBox(width: AppSizes.padding / 2),
                Text(
                  AuthService().getAuthData()?.displayName ?? '-',
                  style: AppTextStyle.bold(size: 12),
                ),
              ],
            ),
            onTap: () async {
              final isEdit = await AppDialog.show(
                child: ProfileDialog(),
                leftButtonText: 'Close',
                rightButtonText: 'Edit Profile',
                onTapRightButton: () => context.pop(true),
              );

              if (isEdit == null) return;

              AppDialog.show(
                title: 'Edit Profile',
                child: EditProfileDialog(),
              );
            },
          ),
          PopupMenuItem(
            height: 40,
            child: Text(
              'Sign Out',
              style: AppTextStyle.semibold(size: 12),
            ),
            onTap: () {
              AppDialog.show(
                title: 'Confirm',
                text: 'Are you sure want to sign out?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Sign Out',
                onTapRightButton: () {
                  ref.read(mainController).onSignOut();
                },
              );
            },
          ),
          PopupMenuItem(
            height: 40,
            child: Text(
              'Export CSV',
              style: AppTextStyle.semibold(size: 12),
            ),
            onTap: () async {
              final confirm = await AppDialog.show(
                title: 'Confirm',
                text: 'Are you sure want to export all the records?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Export',
                onTapRightButton: () => context.pop(true),
              );

              if (confirm == null) return;

              AppDialog.showDialogProgress();
              await ref.read(mainController).exportCsv();
              AppDialog.closeDialog();
            },
          ),
          PopupMenuItem(
            height: 40,
            child: Text(
              'Clear Chat',
              style: AppTextStyle.semibold(size: 12),
            ),
            onTap: () {
              AppDialog.show(
                title: 'Confirm',
                text: 'Are you sure want to clear current chat?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Delete',
                onTapRightButton: () {
                  context.pop();
                  ref.read(chatController).clearChats();
                },
              );
            },
          ),
          PopupMenuItem(
            height: 40,
            child: Text(
              'About',
              style: AppTextStyle.semibold(size: 12),
            ),
            onTap: () {
              AppDialog.show(
                child: AboutAppDialog(),
                leftButtonText: 'Close',
                rightButtonText: 'GitHub ↗️',
                onTapRightButton: () {
                  openLink(Constant.githubRepo);
                },
              );
            },
          ),
          PopupMenuItem(
            height: 32,
            enabled: false,
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: AppColors.blackLv5,
              child: Text(
                'App version: ${version ?? '0.0.0'}',
                style: AppTextStyle.semibold(
                  size: 11,
                  color: AppColors.blackLv3,
                ),
              ),
            ),
          ),
        ];
      },
    );
  }

  Widget bottomNavBar() {
    return Container(
      constraints: BoxConstraints(maxWidth: AppSizes.maxWidth, maxHeight: 66),
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.blackLv6,
        border: Border(
          top: BorderSide(width: 1, color: AppColors.blackLv5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Chat',
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.zero,
              buttonColor: _calculateSelectedIndex() == 0 ? null : Colors.white,
              borderColor: _calculateSelectedIndex() == 0
                  ? null
                  : AppColors.blackLv1,
              onTap: () => _onItemTapped(0),
            ),
          ),
          SizedBox(width: AppSizes.padding / 2),
          Expanded(
            child: AppButton(
              text: 'History',
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.zero,
              buttonColor: _calculateSelectedIndex() == 1 ? null : Colors.white,
              borderColor: _calculateSelectedIndex() == 1
                  ? null
                  : AppColors.blackLv1,
              onTap: () => _onItemTapped(1),
            ),
          ),
          SizedBox(width: AppSizes.padding / 2),
          Expanded(
            child: AppButton(
              text: 'Recap',
              borderRadius: BorderRadius.circular(100),
              padding: EdgeInsets.zero,
              buttonColor: _calculateSelectedIndex() == 2 ? null : Colors.white,
              borderColor: _calculateSelectedIndex() == 2
                  ? null
                  : AppColors.blackLv1,
              onTap: () => _onItemTapped(2),
            ),
          ),
        ],
      ),
    );
  }
}
