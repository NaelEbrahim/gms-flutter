import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final forgotFormKey = GlobalKey<FormState>();
  TextEditingController forgotEmailController = TextEditingController();

  @override
  void dispose() {
    forgotEmailController.dispose();
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
            foregroundColor: Colors.white,
            backgroundColor: Constant.scaffoldColor,
            elevation: 0,
            centerTitle: true,
            title: reusableText(
              content: "Forgot Password",
              fontColor: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Icon(Icons.lock_reset, size: 100, color: Colors.teal),
                const SizedBox(height: 20),
                reusableText(
                  content: "Step 1 of 3",
                  fontColor: Colors.teal,
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
                Form(
                  key: forgotFormKey,
                  child: Card(
                    color: Constant.scaffoldColor,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: forgotEmailController,
                        hint: "example@gmail.com",
                        prefixIcon: Icon(Icons.email, color: Colors.teal),
                        textInputType: TextInputType.emailAddress,
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'email is required';
                          } else if (!RegExp(
                            Constant.emailRegex,
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
                ConditionalBuilder(
                  condition: state is! LoadingState,
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (forgotFormKey.currentState!.validate()) {
                        Manager.get(
                          context,
                        ).forgotPassword({'email': forgotEmailController.text});
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
