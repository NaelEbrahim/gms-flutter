import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

import 'VerifyCode.dart';

final _forgotFormKey = GlobalKey<FormState>();
final _forgotEmailController = TextEditingController();

class ForgotPassword extends StatelessWidget {
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
            MaterialPageRoute(
              builder: (context) => VerifyCode(_forgotEmailController.text),
            ),
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
              content: "Forgot Password",
              fontColor: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 20),
                reusableText(
                  content: "Step 1 of 3",
                  fontColor: Colors.teal.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                reusableText(
                  content:
                      "Enter your registered email to receive a reset code",
                  fontColor: Colors.white70,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Card Input
                Form(
                  key: _forgotFormKey,
                  child: Card(
                    color: Constant.scaffoldColor,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: _forgotEmailController,
                        hint: "example@gmail.com",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.teal.shade700,
                        ),
                        textInputType: TextInputType.emailAddress,
                        radius: 12,
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
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Button
                ConditionalBuilder(
                  condition: state is! LoadingState,
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (_forgotFormKey.currentState!.validate()) {
                        manager.forgotPassword({
                          'email': _forgotEmailController.text,
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
                          content: "Send Code",
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
        );
      },
    );
  }
}
