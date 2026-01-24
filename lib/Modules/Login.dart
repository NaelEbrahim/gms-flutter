import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/ForgotPassword/ForgotPassword.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import 'Base.dart';

final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final visibleScreenHeight = screenHeight - keyboardHeight;

    const double closedHeaderFactor = 0.45;
    const double openHeaderFactor = 0.20;

    final double targetHeaderHeight = keyboardHeight > 0
        ? visibleScreenHeight * openHeaderFactor
        : screenHeight * closedHeaderFactor;

    final double finalHeaderHeight = targetHeaderHeight < 100
        ? 100
        : targetHeaderHeight;
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        // success
        if (state is SuccessState) {
          ReusableComponents.showToast(
            Manager.get(context).message.toString(),
            background: Colors.green,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Base()),
            (route) => false,
          );
          _emailController.clear();
          _passwordController.clear();
        }
        // error
        if (state is ErrorState) {
          ReusableComponents.showToast(
            state.error.toString(),
            background: Colors.red,
          );
        }
      },
      builder: (context, state) {
        var manager = Manager.get(context);
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bodyHeight = constraints.maxHeight;
                final double bottomContentMinHeight =
                    bodyHeight - finalHeaderHeight;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: finalHeaderHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade700,
                              Constant.scaffoldColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (keyboardHeight == 0) ...[
                              Image.asset(
                                'images/logo.png',
                                height: 180,
                                width: 220,
                              ),
                              const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Login to continue",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ] else
                              const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: bottomContentMinHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 30,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                reusableTextFormField(
                                  hint: 'Email Address',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                  ),
                                  controller: _emailController,
                                  textInputType: TextInputType.emailAddress,
                                  radius: 15,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'email is required';
                                    } else if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
                                    ).hasMatch(value)) {
                                      return 'invalid email format';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                reusableTextFormField(
                                  hint: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  controller: _passwordController,
                                  obscureText: manager.eyeVisible,
                                  suffixIcon: manager.eyeIcon,
                                  suffixIconFunction: () {
                                    manager.togglePasswordVisibility();
                                  },
                                  textInputAction: TextInputAction.done,
                                  radius: 15,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'password is required';
                                    }
                                    if (value.length < 8) {
                                      return 'must be at least 8 characters';
                                    }
                                    if (!RegExp(
                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$&*])\S{8,}$',
                                    ).hasMatch(value)) {
                                      return 'Password must contain 1 uppercase, 1 lowercase, 1 digit and 1 special char';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPassword(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                ConditionalBuilder(
                                  condition: state is! LoadingState,
                                  builder: (context) => GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        manager.login({
                                          'email': _emailController.text,
                                          'password':
                                              _passwordController.text,
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.teal.shade700,
                                            Constant.scaffoldColor,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.shade700,
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  fallback: (context) => Center(
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: keyboardHeight > 0 ? keyboardHeight : 0,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
