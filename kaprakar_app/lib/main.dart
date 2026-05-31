import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kaprakar_app/services/journey_service.dart';
import 'package:kaprakar_app/repositories/order_repository.dart';
import 'package:kaprakar_app/repositories/tailor_repository.dart';
import 'package:kaprakar_app/repositories/notification_repository.dart';
import 'package:kaprakar_app/services/notification_service.dart';
import 'package:kaprakar_app/services/tailor_service.dart';
import 'package:kaprakar_app/repositories/chat_repository.dart';
import 'package:kaprakar_app/services/chat_service.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguage = prefs.getString('language_code');
  Locale? initialLocale;
  if (savedLanguage != null) {
    initialLocale = Locale(savedLanguage);
  }

  runApp(KapraKarApp(initialLocale: initialLocale));
}

class KapraKarApp extends StatefulWidget {
  final Locale? initialLocale;
  const KapraKarApp({super.key, this.initialLocale});

  static void setLocale(BuildContext context, Locale newLocale) {
    _KapraKarAppState? state = context.findAncestorStateOfType<_KapraKarAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<KapraKarApp> createState() => _KapraKarAppState();
}

class _KapraKarAppState extends State<KapraKarApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OrderRepository>(create: (_) => ApiOrderRepository()),
        Provider<TailorRepository>(create: (_) => ApiTailorRepository()),
        Provider<ChatRepository>(create: (_) => ApiChatRepository()),
        Provider<NotificationRepository>(create: (_) => ApiNotificationRepository()),
        ChangeNotifierProvider(create: (context) {
          final service = JourneyService();
          service.injectRepository(context.read<OrderRepository>());
          return service;
        }),
        ChangeNotifierProvider(create: (context) => TailorService(context.read<TailorRepository>())),
        ChangeNotifierProvider(create: (context) => ChatService(context.read<ChatRepository>())),
        ChangeNotifierProvider(create: (context) => NotificationService(context.read<NotificationRepository>())),
      ],
      child: MaterialApp(
        navigatorKey: globalNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'KapraKar',
        theme: AppTheme.lightTheme,
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ur'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}