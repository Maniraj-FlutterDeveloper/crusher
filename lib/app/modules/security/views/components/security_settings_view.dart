import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/security_controller.dart';

class SecuritySettingsView extends GetView<SecurityController> {
  const SecuritySettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildSettingsForm(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Security Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsForm() {
    return Obx(() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordSection(),
            const SizedBox(height: 24),
            _buildSessionSection(),
            const SizedBox(height: 24),
            _buildAuditSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      );
    });
  }
  
  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: controller.passwordMinLength.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Minimum Password Length',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final length = int.tryParse(value);
                  if (length != null && length > 0) {
                    controller.passwordMinLength.value = length;
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: controller.passwordExpiryDays.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Password Expiry (Days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final days = int.tryParse(value);
                  if (days != null && days > 0) {
                    controller.passwordExpiryDays.value = days;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Require Uppercase Letters'),
          value: controller.passwordRequireUppercase.value,
          onChanged: (value) {
            if (value != null) {
              controller.passwordRequireUppercase.value = value;
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Require Lowercase Letters'),
          value: controller.passwordRequireLowercase.value,
          onChanged: (value) {
            if (value != null) {
              controller.passwordRequireLowercase.value = value;
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Require Numbers'),
          value: controller.passwordRequireNumbers.value,
          onChanged: (value) {
            if (value != null) {
              controller.passwordRequireNumbers.value = value;
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Require Special Characters'),
          value: controller.passwordRequireSpecialChars.value,
          onChanged: (value) {
            if (value != null) {
              controller.passwordRequireSpecialChars.value = value;
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Security',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: controller.sessionTimeoutMinutes.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Session Timeout (Minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final minutes = int.tryParse(value);
                  if (minutes != null && minutes > 0) {
                    controller.sessionTimeoutMinutes.value = minutes;
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: controller.maxLoginAttempts.value.toString(),
                decoration: const InputDecoration(
                  labelText: 'Max Login Attempts',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final attempts = int.tryParse(value);
                  if (attempts != null && attempts > 0) {
                    controller.maxLoginAttempts.value = attempts;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: controller.lockoutDurationMinutes.value.toString(),
          decoration: const InputDecoration(
            labelText: 'Account Lockout Duration (Minutes)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final minutes = int.tryParse(value);
            if (minutes != null && minutes > 0) {
              controller.lockoutDurationMinutes.value = minutes;
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildAuditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audit Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: controller.auditLogRetentionDays.value.toString(),
          decoration: const InputDecoration(
            labelText: 'Audit Log Retention (Days)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final days = int.tryParse(value);
            if (days != null && days > 0) {
              controller.auditLogRetentionDays.value = days;
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => controller.loadSecuritySettings(),
          child: const Text('Reset'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: controller.isProcessing.value
              ? null
              : () => controller.saveSecuritySettings(),
          child: controller.isProcessing.value
              ? const CircularProgressIndicator()
              : const Text('Save Settings'),
        ),
      ],
    );
  }
}

