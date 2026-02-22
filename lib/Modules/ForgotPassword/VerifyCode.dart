import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';

class VerifyCode extends StatefulWidget {
  final String email;

  const VerifyCode(this.email, {super.key});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final verifyFormKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
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
              content: "Verify Code",
              fontColor: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Icon(Icons.verified, size: 100, color: Colors.teal),
                const SizedBox(height: 20),
                reusableText(
                  content: "Step 2 of 3",
                  fontColor: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                reusableText(
                  content: "Enter the 6-digit code we sent to your email",
                  fontColor: Colors.white70,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Form(
                  key: verifyFormKey,
                  child: Card(
                    elevation: 6,
                    color: Constant.scaffoldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: codeController,
                        hint: "123456",
                        prefixIcon: Icon(Icons.pin, color: Colors.teal),
                        textInputType: TextInputType.number,
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'code is required';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'code must consist of 6 digits';
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
                      if (verifyFormKey.currentState!.validate()) {
                        Manager.get(context).verifyCode({
                          'email': widget.email,
                          'code': codeController.text,
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
                          content: "Verify",
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
