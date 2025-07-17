import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Check if user is already logged in
    if (_authService.isLoggedIn()) {
      Future.delayed(Duration.zero, () {
        Get.offAllNamed(Routes.HOME);
      });
    }
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  // Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }
  
  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
  
  // Login
  Future<void> login() async {
    // Clear previous error message
    errorMessage.value = '';
    
    // Validate form
    if (loginFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        
        final bool success = await _authService.login(
          usernameController.text.trim(),
          passwordController.text.trim(),
        );
        
        if (success) {
          Get.offAllNamed(Routes.HOME);
        } else {
          errorMessage.value = 'Invalid username or password';
        }
      } catch (e) {
        errorMessage.value = 'An error occurred. Please try again.';
        print('Login error: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }
}

