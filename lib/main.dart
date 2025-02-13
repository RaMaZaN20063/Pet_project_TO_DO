import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/api/firebase_api.dart';
import 'package:todo_app/bloc/theme_cubit.dart';
import 'package:todo_app/bottom_navigation.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/screens/sign_up.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // await FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo',
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            primaryColor: Colors.indigo,
          ),
          home: _auth.currentUser != null ? BottomNavigation() : SignUpScreen(),
        );
      }),
    );
  }
}
