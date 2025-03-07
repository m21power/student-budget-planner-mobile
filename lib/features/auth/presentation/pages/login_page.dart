import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackathon_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hackathon_mobile/features/auth/presentation/pages/regiser_page.dart';
import 'package:hackathon_mobile/features/home/presentation/pages/bottom_nav_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool showPassword = false;
  String email = '';
  String password = '';
  Map<String, String> error = {};
  bool isLoading = false;

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Handle successful login state
          if (state is AuthLoginSuccessState) {
            // Delay navigation after build
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => BottomNavPage()));
            });
            isLoading = false;
          }

          // Handle failure state
          if (state is AuthFailureState) {
            // Delay the snack bar to ensure it's shown after build
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: Duration(seconds: 2),
                ),
              );
            });
            isLoading = false;
          }

          return Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hello, Welcome back!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please sign in to the app for tracking your daily bills',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 24),

                  // Email Input
                  TextField(
                    onChanged: (value) => email = value,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                      errorText: error['email'],
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Password Input
                  TextField(
                    onChanged: (value) => password = value,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      errorText: error['password'],
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      if (password.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(LoginEvent(
                            email: email,
                            password: password,
                          ));
                      setState(() {
                        isLoading = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text('Login'),
                  ),
                  SizedBox(height: 16),

                  // Signup Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SignUpPage();
                      }));
                    },
                    child: Text('Don’t have an account? Signup'),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
