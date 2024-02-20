import 'package:dart_openai/dart_openai.dart';
import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:deduct_ai/provider/case_provider.dart';
import 'package:deduct_ai/screens/camera_screen.dart';
import 'package:deduct_ai/screens/charge_screen.dart';
import 'package:deduct_ai/screens/object_screen.dart';
import 'package:deduct_ai/screens/protocol_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:deduct_ai/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.dotenv.load(fileName: "assets/.env");
  OpenAI.apiKey = dotenv.dotenv.env['OPEN_AI_API_KEY']!;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CaseProvider()),
      ],
      child: MaterialApp(
        title: 'Deduct-AI',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: AppColors.appTheme,
        ),
        home: const HomeScreen(title: 'Deduct AI'),
        routes: {
          '/camera': (context) => const CameraScreen(),
          '/objects': (context) => ObjectScreen(),
          '/protocol': (context) => ProtocolScreen(),
          '/charge': (context) => ChargeScreen(),
        },
      ),
    );
  }
}
