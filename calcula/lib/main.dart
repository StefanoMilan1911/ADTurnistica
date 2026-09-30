import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Rome'));
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await notifications.initialize(settings: settings);
  final android = notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await android?.requestNotificationsPermission();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const CartellinoApp());
}

class CartellinoApp extends StatelessWidget {
  const CartellinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartellino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1C2B39),
        scaffoldBackgroundColor: const Color(0xFFEEF1EF),
      ),
      home: const CartellinoWebView(),
    );
  }
}

class CartellinoWebView extends StatefulWidget {
  const CartellinoWebView({super.key});

  @override
  State<CartellinoWebView> createState() => _CartellinoWebViewState();
}

class _CartellinoWebViewState extends State<CartellinoWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _appUrl =
      'https://stefanomilan1911.github.io/ADTurnistica/';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFEEF1EF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            _scheduleTomorrowReminder();
          },
        ),
      )
      ..addJavaScriptChannel(
        'ExportBackup',
        onMessageReceived: (JavaScriptMessage message) {
          _handleExport(message.message);
        },
      );

    // Selettore file nativo per l'import del backup (Android non lo fa da solo).
    if (_controller.platform is AndroidWebViewController) {
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setOnShowFileSelector(_androidFilePicker);
    }

    // Cache-busting sull'URL: garantisce contenuto sempre fresco, sia su
    // installazione pulita sia dopo un aggiornamento, senza dipendere da
    // clearCache() (che su alcune installazioni pulite dava errore ERR_*).
    final freshUrl =
        '$_appUrl?v=${DateTime.now().millisecondsSinceEpoch}';
    _controller.loadRequest(Uri.parse(freshUrl));
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);
      if (files.isEmpty || files.single.path == null) return [];
      return [Uri.file(files.single.path!).toString()];
    } catch (e) {
      return [];
    }
  }

  // Legge i turni di domani dalla pagina e programma il promemoria per stasera alle 20.
  Future<void> _scheduleTomorrowReminder() async {
    try {
      final raw = await _controller
          .runJavaScriptReturningResult('window.getTomorrowShifts()');
      var jsonStr = raw.toString();
      if (jsonStr.startsWith('"')) {
        jsonStr = jsonDecode(jsonStr) as String;
      }
      final List<dynamic> shifts = jsonDecode(jsonStr);
      await notifications.cancel(id: 1);
      if (shifts.isEmpty) return;

      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
      if (when.isBefore(now)) return; // troppo tardi per oggi

      await notifications.zonedSchedule(
        id: 1,
        title: 'Turno di domani',
        body: shifts.join(' + '),
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'turni_domani',
            'Promemoria turni',
            channelDescription: 'Avviso serale sul turno del giorno dopo',
            importance: Importance.defaultImportance,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      // se qualcosa non va, l'app funziona lo stesso senza notifica
    }
  }

  Future<void> _handleExport(String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cartellino-backup.json');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Cartellino',
      );
    } catch (e) {
      // Fallisce in silenzio: se serve, mostra un messaggio all'utente qui.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD98E3D),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}