import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:frontend/features/home/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => LoginPage());

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(state.error),
                ),
              ),
            );
          } else if (state is AuthLoggedIn) {
            Navigator.pushAndRemoveUntil(
                context, HomePage.route(), (_) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign In",
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(fontSize: 18),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email field cannot be empty!";
                      }
                      if (!value.contains('@')) {
                        return "Invalid Email!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Email",
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    style: TextStyle(fontSize: 18),
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Password field cannot be empty";
                      }
                      if (value.length < 6) {
                        return "Password must be of minimum 6 letters!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: loginUser,
                    child: Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 17, color: Colors.grey.shade500),
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SignupPage.route());
                    },
                    child: RichText(
                      text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
