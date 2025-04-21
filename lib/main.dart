import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:maintenance2/features/home_page/presentation/home_page.dart';
import 'package:maintenance2/core/services/error_handler.dart';
import 'package:maintenance2/core/services/excel_service.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Main entry point of the application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    developer.log('Starting application initialization...');

    // Clear SharedPreferences and delete database
    await _resetDatabase();

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isDataImported = prefs.getBool('isDataImported') ?? false;

    // Copy Excel file from assets to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final excelFile = File('${directory.path}/SREENFRESH.xlsx');

    // Check if file already exists in documents directory
    if (!await excelFile.exists()) {
      developer.log('Copying Excel file to documents directory...');
      final ByteData data = await rootBundle.load(
        'assets/sheets/SREENFRESH.xlsx',
      );
      final List<int> bytes = data.buffer.asUint8List();
      await excelFile.writeAsBytes(bytes);
      developer.log('Excel file copied successfully');
    }

    // Only import data if it hasn't been imported before
    if (!isDataImported) {
      developer.log('Starting initial data import...');
      final excelService = ExcelService();
      await excelService.importExcelData();
      await prefs.setBool('isDataImported', true);
      developer.log('Data import completed successfully');
    } else {
      developer.log('Data already imported, skipping import process');
    }

    // Start the application
    runApp(const MyApp());
  } catch (e) {
    // Use the error handler for initialization errors
    runApp(ErrorHandler.handleInitializationError(e));
  }
}

// Helper method to reset database and preferences
Future<void> _resetDatabase() async {
  try {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Delete database file
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'maintenance.db'));
    if (await dbFile.exists()) {
      await dbFile.delete();
      developer.log('Database file deleted successfully');
    }

    // Delete Excel file from documents directory
    final directory = await getApplicationDocumentsDirectory();
    final excelFile = File('${directory.path}/SREENFRESH.xlsx');
    if (await excelFile.exists()) {
      await excelFile.delete();
      developer.log('Excel file deleted successfully');
    }
  } catch (e) {
    developer.log('Error resetting database: $e', error: e);
  }
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ErrorHandler.navigatorKey,
      debugShowCheckedModeBanner: false,
      // App,lication title,
      title: 'صيانة عاصمة المجد',
      // Theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      // Localization delegates for Arabic support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Supported locales (Arabic)
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      // Default locale
      locale: const Locale('ar'),
      // Home screen
      home: const HomePage(),
    );
  }
}
