import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/db_service.dart';
import 'app/data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite_ffi for Windows
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  
  // Set minimum window size for desktop
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    setWindowTitle('Crusher Management System');
    setWindowMinSize(const Size(1024, 768));
    setWindowMaxSize(Size.infinite);
  }
  
  // Initialize services
  await initServices();
  
  runApp(const CrusherManagementApp());
}

/// Initialize services before the app starts
Future<void> initServices() async {
  print('Initializing services...');
  
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());
  
  // Initialize database service
  await Get.putAsync(() => DbService().init());
  
  print('All services initialized');
}

class CrusherManagementApp extends StatelessWidget {
  const CrusherManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crusher Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default theme mode
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

