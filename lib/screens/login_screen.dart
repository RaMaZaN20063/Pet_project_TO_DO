import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/bottom_navigation.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/screens/sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late final AnimationController _controller;
  bool _isLoggingIn = false; // To track login status

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void _addListenerForNavigation() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigation(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggingIn == false
        ? Form(
            key: _formKey,
            child: Scaffold(
              backgroundColor: Color(0xFF1d2630),
              appBar: AppBar(
                backgroundColor: Color(0xFF1d2630),
                foregroundColor: Colors.white,
                title: Text('Create Account'),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Welcome back',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Log In Here',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is empty';
                          }
                          final emailRegex =
                              RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid Gmail address';
                          }
                          return null;
                        },
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is empty';
                          }
                          return null;
                        },
                        obscureText: true,
                        controller: _passwordcontroller,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                      SizedBox(height: 50),
                      // if (_isLoggingIn)
                      // Lottie.network('https://assets10.lottiefiles.com/packages/lf20_Cc8Bpg.json'),  // Show animation while logging in
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              User? result =
                                  await _auth.signInWithEmailandPassword(
                                      _emailcontroller.text,
                                      _passwordcontroller.text);

                              if (result != null) {
                                print('Sign in successful');
                                setState(() {
                                  _isLoggingIn = true;
                                });
                                _addListenerForNavigation();
                                _controller.forward();
                              } else {
                                setState(() {
                                  _isLoggingIn = false;
                                });
                                print('Sign in failed');
                              }
                            }
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'OR',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container(
            color: Color(0xFF1d2630),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Center(
                child: Lottie.network(
                    'https://assets10.lottiefiles.com/packages/lf20_Cc8Bpg.json'),
              ),
            ]));
  }
}
