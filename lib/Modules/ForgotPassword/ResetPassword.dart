import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';

import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword(this.email, {super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isNewPasswordHide = true;
  bool isConfirmNewPasswordHide = true;
  final resetFormKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        // error
        if (state is ErrorState) {
          ReusableComponents.showToast(
            state.error.toString(),
            background: Colors.red,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Constant.scaffoldColor,
            elevation: 0,
            centerTitle: true,
            title: reusableText(
              content: "Reset Password",
              fontColor: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: resetFormKey,
              child: Column(
                children: [
                  Icon(Icons.lock, size: 100, color: Colors.teal),
                  const SizedBox(height: 20),
                  reusableText(
                    content: "Step 3 of 3",
                    fontColor: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 10),
                  reusableText(
                    content: "Enter and confirm your new password",
                    fontColor: Colors.white70,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 6,
                    color: Constant.scaffoldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: newPasswordController,
                        hint: "New Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        obscureText: isNewPasswordHide,
                        suffixIcon: isNewPasswordHide
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixIconFunction: () {
                          setState(() {
                            isNewPasswordHide = !isNewPasswordHide;
                          });
                        },
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'password is required';
                          }
                          if (value.length < 8) {
                            return 'must be at least 8 characters';
                          }
                          if (!RegExp(Constant.passwordRegex).hasMatch(value)) {
                            return 'password must contain 1 uppercase, 1 lowercase, 1 digit and 1 special char';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 6,
                    color: Constant.scaffoldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: confirmPasswordController,
                        hint: "Confirm Password",
                        prefixIcon: Icon(Icons.lock_reset),
                        obscureText: isConfirmNewPasswordHide,
                        suffixIcon: isConfirmNewPasswordHide
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixIconFunction: () {
                          setState(() {
                            isConfirmNewPasswordHide =
                                !isConfirmNewPasswordHide;
                          });
                        },
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'confirm password is required';
                          }
                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            return 'passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConditionalBuilder(
                    condition: state is! LoadingState,
                    builder: (context) => GestureDetector(
                      onTap: () {
                        if (resetFormKey.currentState!.validate()) {
                          Manager.get(context).resetForgotPassword({
                            'email': widget.email,
                            'newPassword': newPasswordController.text,
                          });
                        }
                      },
                      child: Container(
                        width: Constant.screenWidth / 2,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: reusableText(
                            content: "Reset Password",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    fallback: (context) =>
                        Center(child: const CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
