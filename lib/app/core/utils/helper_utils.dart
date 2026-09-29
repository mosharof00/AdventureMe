import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adventureme/app/data/repositories/auth_repository.dart';
import 'package:adventureme/app/global/widgets/global_loading.dart';
import 'package:adventureme/app/modules/home/controllers/home_controller.dart';

import '../../modules/main_page/controllers/main_page_controller.dart';
import '../network/token_refresher.dart';
import '../../routes/app_pages.dart';
import '../services/local_store_service.dart';
import '../services/secure_storage_service.dart';
import 'dialog_utils.dart';
import 'logger.dart';


class HelperUtils {

  /// Default currency symbol
  static String currencySymbol = "\$";


  static String defaultProfileImage =
      // "https://i.pinimg.com/474x/18/b5/b5/18b5b599bb873285bd4def283c0d3c09.jpg";
      "https://i.pinimg.com/1200x/6e/59/95/6e599501252c23bcf02658617b29c894.jpg";
      // "https://i.pinimg.com/736x/43/8a/28/438a28f0b12098c4cc1516ffb0378ccf.jpg";
  static bool isOnboard = false;
  static bool isLoggedIn = false;
  static bool isAdmin = false;

  static String firebaseToken = "";
  static bool isLogin = false;
  static String token = "";
  static String userId = "";
  static String userRole = "";

  /// Whether the current session is saved in secure storage (Remember Me);
  /// refreshed tokens follow the same rule.
  static bool _persisted = false;


  // -----------------------------
  // Save / login user (updates runtime, and storage when [persist] is true)
  // -----------------------------
  /// With [persist] false (Remember Me off) the session lives only in memory,
  /// so the next cold start lands on the login screen.
  static Future<void> setUser({
    required String userId,
    required String token,
    String? role,
    bool persist = true,
  }) async {
    final storage = SecureStorageService.instance;

    if (persist) {
      await storage.setUserID(userId);
      await storage.setToken(token);
      if (role != null) await storage.setUserRole(role);
    } else {
      await storage.clearAll();
    }

    HelperUtils.userId = userId;
    HelperUtils.token = token;
    HelperUtils.userRole = role ?? '';
    HelperUtils.isLogin = true;
    _persisted = persist;

    Log.i(
      "✅ User set:\nUserId: $userId\nRole: ${role ?? ''}\nPersisted: $persist",
    );
  }

  /// Swaps in a refreshed access token, saving it only if the session is
  /// persisted.
  static Future<void> updateToken(
    String newToken, {
    String? userId,
    String? role,
  }) async {
    token = newToken;
    if (userId != null && userId.isNotEmpty) HelperUtils.userId = userId;
    if (role != null && role.isNotEmpty) userRole = role;

    if (_persisted) {
      final storage = SecureStorageService.instance;
      await storage.setToken(newToken);
      if (userId != null && userId.isNotEmpty) await storage.setUserID(userId);
      if (role != null && role.isNotEmpty) await storage.setUserRole(role);
    }
  }

  // -----------------------------
  // Check if user is logged in (reads from storage)
  // -----------------------------
  /// Restores the session from secure storage. An expired token is refreshed;
  /// if the server rejects it the session is cleared. When the refresh can't
  /// reach the server, the session is kept and refreshed on the next request.
  static Future<bool> checkLoginStatus() async {
    final storage = SecureStorageService.instance;

    final storedId = await storage.getUserID();
    final storedToken = await storage.getToken();

    final hasSession = (storedId?.isNotEmpty ?? false) &&
        (storedToken?.isNotEmpty ?? false);

    if (!hasSession) {
      Log.w("Guest User! \nUserId: $storedId \nToken: $storedToken");
      isLogin = false;
      return false;
    }

    userId = storedId!;
    token = storedToken!;
    userRole = await storage.getUserRole() ?? '';
    isLogin = true;
    _persisted = true;

    if (isTokenExpired(storedToken, leeway: tokenRefreshLeeway)) {
      Log.w("Stored token expired — refreshing.");
      final result = await TokenRefresher.refresh();
      if (result == RefreshResult.rejected) {
        await clearUser();
        return false;
      }
    }

    Log.i("✅ Session restored\nUserId: $userId\nRole: $userRole");
    return true;
  }

  /// Tokens this close to expiry are refreshed before use.
  static const Duration tokenRefreshLeeway = Duration(seconds: 60);

  /// Reads the `exp` claim of a JWT (optionally [leeway] early). Tokens that
  /// can't be decoded or carry no `exp` are treated as not expired and left
  /// for the server to reject.
  static bool isTokenExpired(String jwt, {Duration leeway = Duration.zero}) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return false;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map ? payload['exp'] : null;
      if (exp is! num) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().add(leeway).isAfter(expiry);
    } catch (_) {
      return false;
    }
  }

  // -----------------------------
  // Clear user (logout)
  // -----------------------------
  static Future<void> clearUser() async {
    final storage = SecureStorageService.instance;
    await storage.clearAll();

    userId = "";
    token = "";
    userRole = "";
    isLogin = false;
    _persisted = false;

    Log.i("✅ User cleared. Logged out.");
  }

  /// Asks for confirmation, then runs [logout].
  static void confirmLogout() {
    DialogUtils.showDialog(
      context: Get.context!,
      dialogType: DialogType.warning,
      title: 'Logout',
      description: 'Are you sure you want to logout?',
      okText: 'Logout',
      cancelText: 'Cancel',
      okOnPress: logout,
      cancelOnPress: () {},
    );
  }

  /// Tells the server to end the session (best effort), then always clears the
  /// local session and resets the stack to the login screen.
  static Future<void> logout() async {
    if (token.isNotEmpty) {
      Get.dialog(
        const PopScope(canPop: false, child: GlobalLoading()),
        barrierDismissible: false,
      );
      try {
        await Get.find<IAuthRepository>()
            .logout()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        Log.w("Logout API failed, clearing local session anyway: $e");
      }
    }
    await _resetToLogin();
  }

  static bool _isHandlingSessionExpiry = false;

  /// Called by [AuthInterceptor] on a 401. Clears the session right away and
  /// shows a dialog; closing it in any way (button, outside tap, back) goes to
  /// login. Guarded so parallel 401s show a single dialog.
  static Future<void> handleSessionExpired([String? message]) async {
    if (_isHandlingSessionExpiry || !isLogin) return;
    _isHandlingSessionExpiry = true;

    await clearUser();

    final context = Get.context;
    if (context == null) {
      await _resetToLogin();
      _isHandlingSessionExpiry = false;
      return;
    }

    DialogUtils.showDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Session Expired',
      description: (message == null || message.isEmpty)
          ? 'Your session has expired. Please sign in again.'
          : message,
      okText: 'Login',
      okOnPress: () {},
      onDismiss: () async {
        await _resetToLogin();
        _isHandlingSessionExpiry = false;
      },
    );
  }

  static Future<void> _resetToLogin() async {
    await clearUser();
    await deleteMainControllers();
    Get.offAllNamed(Routes.LOGIN);
  }

  /// Returns to the existing main page (keeping its controllers and state) and
  /// switches to [tab]. Falls back to a fresh main page if it isn't in the stack.
  static void backToMain({int tab = 0}) {
    var found = false;
    Get.until((route) {
      found = route.settings.name == Routes.MAIN_PAGE;
      return found || route.isFirst;
    });

    if (found && Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(tab);
    } else {
      Get.offAllNamed(Routes.MAIN_PAGE);
    }
  }


  ///  Languages
  static Locale locateLanguage() {
    return Locale(language(), language().toUpperCase());
  }

  static String language() {
    return HiveService.getLanguage().split('_')[0] ?? 'en';
  }

  static Future<void> deleteMainControllers() async {
    if (Get.isRegistered<MainPageController>()) {
      Get.delete<MainPageController>(force: true);
    }
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>(force: true);
    }

    // if (Get.isRegistered<CartController>()) {
    //   Get.delete<CartController>(force: true);
    // }
  }

  static Future<void> navigateToOrder() async {
    // Refresh cart since it's now empty after order placement
    // if (Get.isRegistered<CartController>()) {
    //   Get.find<CartController>().fetchCart();
    // }
    Get.offAllNamed(Routes.MAIN_PAGE);
    // Use a delay to ensure MainPageController is initialized then switch to My Orders tab (index 3)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.isRegistered<MainPageController>()) {
        // Get.find<MainPageController>().changeTab(3);
      }
    });
  }
}
