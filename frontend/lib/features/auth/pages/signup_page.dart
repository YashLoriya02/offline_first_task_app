import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => SignupPage());

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signupUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
          name: nameController.text.trim(),
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
          } else if (state is AuthSignUp) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text("Account Created successfully! Kindly Login!"),
                ),
              ),
            );
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
                  Text("Sign Up",
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(fontSize: 18),
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter Name",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name field cannot be empty!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
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
                    onPressed: signupUser,
                    child: Text(
                      'SIGN UP',
                      style:
                          TextStyle(fontSize: 17, color: Colors.grey.shade500),
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(LoginPage.route());
                    },
                    child: RichText(
                      text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign In',
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
