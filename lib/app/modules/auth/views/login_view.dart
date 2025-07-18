import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/utils/responsive_builder.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, deviceType, size) {
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: deviceType == DeviceScreenType.mobile
                    ? size.width * 0.9
                    : deviceType == DeviceScreenType.tablet
                        ? size.width * 0.7
                        : size.width * 0.4,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and title
                    Column(
                      children: [
                        Icon(
                          Icons.business,
                          size: 64,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Crusher Management System',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to your account',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textLightColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Login form
                    Form(
                      key: controller.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username field
                          TextFormField(
                            controller: controller.usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: controller.validateUsername,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          Obx(() => TextFormField(
                                controller: controller.passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                obscureText: controller.obscurePassword.value,
                                validator: controller.validatePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => controller.login(),
                              )),
                          const SizedBox(height: 8),
                          
                          // Error message
                          Obx(() => controller.errorMessage.value.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: TextStyle(
                                      color: AppColors.errorColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : const SizedBox.shrink()),
                          const SizedBox(height: 24),
                          
                          // Login button
                          Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value ? null : controller.login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Footer
                    Text(
                      '© ${DateTime.now().year} Crusher Management System',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLightColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

