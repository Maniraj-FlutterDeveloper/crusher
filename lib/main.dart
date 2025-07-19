import 'package:crusher_management/app/core/error/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/db_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/data/services/auth_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/values/app_constants.dart';
import 'app/core/error/global_error_handler.dart';
import 'app/core/services/logger_service.dart';
import 'app/data/repositories/audit_log_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set minimum window size for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(AppConstants.appName);
    setWindowMinSize(const Size(1024, 768));
    setWindowMaxSize(Size.infinite);
  }
  
  // Initialize services
  await initServices();
  
  // Initialize error handling
  final globalErrorHandler = initErrorHandling();
  globalErrorHandler.initialize();
  
  runApp(const MyApp());
}

// Initialize services
Future<void> initServices() async {
  print('Initializing services...');
  
  // Initialize logger service
  final logger = LoggerService();
  await logger.init();
  Get.put(logger, permanent: true);
  
  // Initialize storage service
  await Get.putAsync(() => StorageService().init());
  
  // Initialize database service
  await Get.putAsync(() => DbService().init());
  
  // Initialize auth service
  await Get.putAsync(() => AuthService().init());
  
  // Initialize repositories
  Get.put(AuditLogRepository(), permanent: true);
  
  print('All services initialized');
}

// Initialize error handling
GlobalErrorHandler initErrorHandling() {
  // Get logger
  final logger = Get.find<LoggerService>();

  // Create error handler
  final errorHandler = ErrorHandler(
    logger: logger,
    auditLogRepository: Get.find<AuditLogRepository>(),
  );
  Get.put(errorHandler, permanent: true);

  // Create global error handler
  final globalErrorHandler = GlobalErrorHandler(
    logger: logger,
    errorHandler: errorHandler,
  );

  return globalErrorHandler;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
