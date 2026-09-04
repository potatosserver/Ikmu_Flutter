// 登入頁面
// 使用 Material 3 設計、Riverpod 狀態管理

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Icon(
                          Icons.local_hospital,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'i高醫',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '高雄醫學大學行動查詢系統',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // 錯誤訊息
                        if (authState.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // 帳號輸入
                        TextFormField(
                          controller: userIdController,
                          decoration: const InputDecoration(
                            labelText: '學號/工號',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '請輸入學號/工號';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          enabled: !authState.isLoading,
                        ),
                        const SizedBox(height: 16),

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
                        ),
                        const SizedBox(height: 16),

                        // 記住我
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe.value,
                              onChanged: authState.isLoading 
                                  ? null 
                                  : (value) => rememberMe.value = value ?? false,
                            ),
                            Text('記住我'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: 忘記密碼
                              },
                              child: const Text('忘記密碼？'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 登入按鈕
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: authState.isLoading ? null : handleLogin,
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text('登入'),
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
    );
  }
}