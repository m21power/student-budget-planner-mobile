import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackathon_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hackathon_mobile/features/auth/presentation/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showPassword = false;
  String name = '';
  String email = '';
  String password = '';
  String errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print(state);
          if (state is AuthRegisterSuccessState) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignInPage()));
          } else if (state is AuthFailureState) {
            setState(() {
              errorMessage = state.message;
              isLoading = false;
            });
          } else if (state is AuthInitial) {
            setState(() {
              isLoading = true;
            });
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create Your Account',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Sign up to start tracking your daily bills'),
                        SizedBox(height: 16),
                        _buildTextField(
                            label: 'Full Name',
                            onChanged: (value) => setState(() => name = value)),
                        SizedBox(height: 16),
                        _buildTextField(
                            label: 'Email Address',
                            onChanged: (value) =>
                                setState(() => email = value)),
                        SizedBox(height: 16),
                        _buildPasswordField(),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (name.isEmpty ||
                                      email.isEmpty ||
                                      password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please fill in all fields'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  context.read<AuthBloc>().add(RegisterEvent(
                                      name: name,
                                      email: email,
                                      password: password));
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.amber,
                                )
                              : const Text('Sign Up'),
                        ),
                        SizedBox(height: 16),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignInPage()));
                              },
                              child: Text('Login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label, required Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      onChanged: (value) => setState(() => password = value),
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
        ),
      ),
    );
  }
}
