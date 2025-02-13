import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/theme_cubit.dart';
import 'package:todo_app/screens/login_screen.dart';
import 'package:todo_app/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

 void _addListenerForNavigation() {
   Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аккаунт'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            icon: const Icon(Icons.brightness_6),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Абиш Рамазан',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'abish@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Редактировать профиль'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async{
                      await AuthService().singOut();
                      _addListenerForNavigation();
                    }, 
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}