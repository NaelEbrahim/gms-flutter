import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/Login.dart';

import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';


class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword(this.email, {super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isNewPasswordHide = true;
  bool _isConfirmNewPasswordHide = true;
  final _resetFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            MaterialPageRoute(builder: (context) => Login()),
            (route) => false,
          );
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
          appBar: AppBar(
            backgroundColor: Constant.scaffoldColor,
            elevation: 0,
            centerTitle: true,
            title: reusableText(
              content: "Reset Password",
              fontColor: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _resetFormKey,
              child: Column(
                children: [
                  Icon(Icons.lock, size: 100, color: Colors.teal.shade700),
                  const SizedBox(height: 20),
                  reusableText(
                    content: "Step 3 of 3",
                    fontColor: Colors.teal.shade700,
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
                        controller: _newPasswordController,
                        hint: "New Password",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.teal.shade700,
                        ),
                        obscureText: _isNewPasswordHide,
                        suffixIcon: _isNewPasswordHide
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixIconFunction: () {
                          setState(() {
                            _isNewPasswordHide = !_isNewPasswordHide;
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
                          if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$&*])\S{8,}$',
                          ).hasMatch(value)) {
                            return 'Password must contain 1 uppercase, 1 lowercase, 1 digit and 1 special char';
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
                        controller: _confirmPasswordController,
                        hint: "Confirm Password",
                        prefixIcon: Icon(
                          Icons.lock_reset,
                          color: Colors.teal.shade700,
                        ),
                        obscureText: _isConfirmNewPasswordHide,
                        suffixIcon: _isConfirmNewPasswordHide
                            ? Icons.visibility
                            : Icons.visibility_off,
                        suffixIconFunction: () {
                          setState(() {
                            _isConfirmNewPasswordHide = !_isConfirmNewPasswordHide;
                          });
                        },
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'confirm password is required';
                          }
                          if (_newPasswordController.text !=
                              _confirmPasswordController.text) {
                            return 'Passwords do not match';
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
                        if (_resetFormKey.currentState!.validate()) {
                          manager.resetForgotPassword({
                            'email': widget.email,
                            'newPassword': _newPasswordController.text,
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade700,
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
