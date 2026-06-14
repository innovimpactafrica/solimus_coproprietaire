import 'package:flutter/material.dart';
import 'screens/splash/splash0.dart';
import 'services/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solimus Prestataire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Splash0(),
    );
  }
}
