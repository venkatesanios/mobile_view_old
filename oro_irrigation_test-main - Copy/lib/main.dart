import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:oro_irrigation_new/MyGemini.dart';
import 'package:oro_irrigation_new/Screens/map/maplatlong_provider.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/DashBoard.dart';
import 'package:oro_irrigation_new/screens/login_form.dart';
import 'package:oro_irrigation_new/state_management/ConnectivityService.dart';
import 'package:oro_irrigation_new/state_management/DurationNotifier.dart';
import 'package:oro_irrigation_new/state_management/FertilizerSetProvider.dart';
import 'package:oro_irrigation_new/state_management/GlobalFertLimitProvider.dart';
import 'package:oro_irrigation_new/state_management/MqttPayloadProvider.dart';
import 'package:oro_irrigation_new/state_management/SelectedGroupProvider.dart';
import 'package:oro_irrigation_new/state_management/condition_provider.dart';
import 'package:oro_irrigation_new/state_management/config_maker_provider.dart';
import 'package:oro_irrigation_new/state_management/constant_provider.dart';
import 'package:oro_irrigation_new/state_management/data_acquisition_provider.dart';
import 'package:oro_irrigation_new/state_management/irrigation_program_main_provider.dart';
import 'package:oro_irrigation_new/state_management/mqtt_message_provider.dart';
import 'package:oro_irrigation_new/state_management/overall_use.dart';
import 'package:oro_irrigation_new/state_management/preference_provider.dart';
import 'package:oro_irrigation_new/state_management/preferences_screen_main_provider.dart';
import 'package:oro_irrigation_new/state_management/program_queue_provider.dart';
import 'package:oro_irrigation_new/state_management/schedule_view_provider.dart';
import 'package:oro_irrigation_new/state_management/system_definition_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() {
  tz.initializeTimeZones();
  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  myMqtt.editMySchedule(mySchedule);
  Gemini.init(
      apiKey: const String.fromEnvironment('AIzaSyC9dGxg8HPz7xpYWr9_k_IMFXNc11PzYkg'), enableDebugging: true);
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ChangeNotifierProvider(create: (context) => ConfigMakerProvider()),
          ChangeNotifierProvider(create: (context) => PreferencesMainProvider()),
          ChangeNotifierProvider(create: (context) => PreferenceProvider()),
          ChangeNotifierProvider(create: (context) => DataAcquisitionProvider()),
          ChangeNotifierProvider(create: (context) => OverAllUse()),
          ChangeNotifierProvider(create: (context) => MessageProvider()),
          ChangeNotifierProvider(create: (context) => IrrigationProgramProvider()),
          ChangeNotifierProvider(create: (context) => ConstantProvider()),
          ChangeNotifierProvider(create: (context) => SelectedGroupProvider()),
          ChangeNotifierProvider(create: (context) => FertilizerSetProvider()),
          ChangeNotifierProvider(create: (context) => GlobalFertLimitProvider()),
          ChangeNotifierProvider(create: (context) => myMqtt),
          ChangeNotifierProvider(create: (context) => SystemDefinitionProvider()),
          ChangeNotifierProvider(create: (context) => ProgramQueueProvider()),
          ChangeNotifierProvider(create: (context) => mySchedule),
          ChangeNotifierProvider(create: (context) => ConditionProvider()),
          ChangeNotifierProvider(create: (context) => MapLatlong()),
          ChangeNotifierProvider(create: (_) => DurationNotifier()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: myTheme.primaryColorDark,
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => const LoginForm(),
        '/dashboard': (context) => const MainDashBoard(),
      },
      // home: MyGemini(),
    );
  }
}