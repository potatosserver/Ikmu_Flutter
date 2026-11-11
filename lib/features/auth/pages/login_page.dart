// 登入頁面
// 使用 Material 3 設計、Riverpod 狀態管理、響應式佈局

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../core.dart';
import '../../../core/ui/responsive.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final userIdController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final rememberMe = useState(false);
    final obscurePassword = useState(true);

    Future<void> handleLogin() async {
      if (formKey.currentState?.validate() ?? false) {
        await authController.login(
          userId: userIdController.text.trim(),
          password: passwordController.text,
          rememberMe: rememberMe.value,
        );
      }
    }

    /// 測試模式：不登入直接進入 App (僅限不需認證的功能)
    Future<void> handleGuestMode() async {
      // 使用 AuthController 新增的 setAuthState 方法
      authController.setAuthState(
        isLoggedIn: true,
        token: 'guest-token',
        userId: 'guest',
        password: '',
        userProfile: const UserProfile(
          userId: 'guest',
          userName: '測試用戶 (Guest)',
          userType: 'guest',
        ),
      );

      // 同步設定 KmuClient token (供 API 呼叫使用)
      final kmuClient = ref.read(kmuClientProvider);
      kmuClient.setCredentials(userId: 'guest', token: 'guest-token');

      if (context.mounted) {
        context.go(RoutePaths.calendar);
      }
    }

    return ResponsiveLayout(
      child: Scaffold(
        body: SafeAreaAdapter(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveSpacing.responsive(context, mobile: 24, tablet: 32, desktop: 48)),
              child: ResponsiveContainer(
                mobileMaxWidth: double.infinity,
                tabletMaxWidth: 440,
                desktopMaxWidth: 440,
                child: Card(
                  elevation: context.responsive.isMobile ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 16, desktop: 20)),
                  ),
                  child: Padding(
                    padding: const ResponsiveValue<EdgeInsetsGeometry>(
                      mobile: EdgeInsets.all(24),
                      tablet: EdgeInsets.all(32),
                      desktop: EdgeInsets.all(40),
                    ).resolve(context),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo - 響應式大小
                          Icon(
                            Icons.local_hospital,
                            size: const ResponsiveValue<double>(
                              mobile: 72,
                              tablet: 88,
                              desktop: 96,
                            ).resolve(context),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 20, desktop: 28)),
                          
                          Text(
                            'i高醫',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: const ResponsiveValue<double>(
                                mobile: 32,
                                tablet: 36,
                                desktop: 40,
                              ).resolve(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 6, desktop: 10)),
                          Text(
                            '高雄醫學大學行動查詢系統',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: const ResponsiveValue<double>(
                                mobile: 15,
                                tablet: 16,
                                desktop: 17,
                              ).resolve(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 28, desktop: 36)),

                          // 錯誤訊息
                          if (authState.error != null)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(ResponsiveSpacing.responsive(context, mobile: 12, desktop: 16)),
                              margin: EdgeInsets.only(bottom: ResponsiveSpacing.responsive(context, mobile: 16, desktop: 20)),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 8, desktop: 10)),
                              ),
                              child: Text(
                                authState.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontSize: const ResponsiveValue<double>(
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ).resolve(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // 帳號輸入
                          TextFormField(
                            controller: userIdController,
                            decoration: InputDecoration(
                              labelText: '學號',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 10, desktop: 12)),
                              ),
                              contentPadding: const ResponsiveValue<EdgeInsetsGeometry>(
                                mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                desktop: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ).resolve(context),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入學號';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            enabled: !authState.isLoading,
                            style: TextStyle(
                              fontSize: const ResponsiveValue<double>(
                                mobile: 16,
                                tablet: 17,
                                desktop: 18,
                              ).resolve(context),
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 14, desktop: 18)),

                          // 密碼輸入
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: '密碼',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => obscurePassword.value = !obscurePassword.value,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 10, desktop: 12)),
                              ),
                              contentPadding: const ResponsiveValue<EdgeInsetsGeometry>(
                                mobile: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                desktop: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ).resolve(context),
                            ),
                            obscureText: obscurePassword.value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入密碼';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            enabled: !authState.isLoading,
                            onFieldSubmitted: (_) => handleLogin(),
                            style: TextStyle(
                              fontSize: const ResponsiveValue<double>(
                                mobile: 16,
                                tablet: 17,
                                desktop: 18,
                              ).resolve(context),
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 14, desktop: 18)),

                          // 記住我 + 忘記密碼
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe.value,
                                onChanged: authState.isLoading
                                    ? null
                                    : (value) => rememberMe.value = value ?? false,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Flexible(
                                child: Text(
                                  '記住我',
                                  style: TextStyle(
                                    fontSize: const ResponsiveValue<double>(
                                      mobile: 14,
                                      tablet: 15,
                                      desktop: 16,
                                    ).resolve(context),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  // TODO: 忘記密碼
                                },
                                child: Text(
                                  '忘記密碼？',
                                  style: TextStyle(
                                    fontSize: const ResponsiveValue<double>(
                                      mobile: 14,
                                      tablet: 15,
                                      desktop: 16,
                                    ).resolve(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 20, desktop: 28)),

                          // 登入按鈕
                          SizedBox(
                            width: double.infinity,
                            height: const ResponsiveValue<double>(
                              mobile: 50,
                              tablet: 52,
                              desktop: 56,
                            ).resolve(context),
                            child: FilledButton(
                              onPressed: authState.isLoading ? null : handleLogin,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 10, desktop: 12)),
                                ),
                                textStyle: TextStyle(
                                  fontSize: const ResponsiveValue<double>(
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ).resolve(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text('登入'),
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.responsive(context, mobile: 10, desktop: 14)),
                          // 測試模式按鈕 (不需登入)
                          SizedBox(
                            width: double.infinity,
                            height: const ResponsiveValue<double>(
                              mobile: 50,
                              tablet: 52,
                              desktop: 56,
                            ).resolve(context),
                            child: OutlinedButton.icon(
                              onPressed: authState.isLoading ? null : handleGuestMode,
                              icon: const Icon(Icons.science_outlined),
                              label: const Text('測試模式 (不登入)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveRadius.responsive(context, mobile: 10, desktop: 12)),
                                ),
                                textStyle: TextStyle(
                                  fontSize: const ResponsiveValue<double>(
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ).resolve(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}