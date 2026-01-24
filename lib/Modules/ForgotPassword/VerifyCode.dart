import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Modules/ForgotPassword/ForgotPassword.dart';

import '../../BLoC/Manager.dart';
import '../../Shared/Components.dart';
import '../../Shared/Constant.dart';
import 'ResetPassword.dart';

final _verifyFormKey = GlobalKey<FormState>();
final _codeController = TextEditingController();

class VerifyCode extends StatelessWidget {
  final String email;

  const VerifyCode(this.email, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager,BLoCStates>(
      listener: (context, state) {
        // success
        if (state is SuccessState) {
          ReusableComponents.showToast(
            Manager.get(context).message.toString(),
            background: Colors.green,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ResetPassword(email)),
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
              content: "Verify Code",
              fontColor: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Icon(Icons.verified, size: 100, color: Colors.teal.shade700),
                const SizedBox(height: 20),
                reusableText(
                  content: "Step 2 of 3",
                  fontColor: Colors.teal.shade700,
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
                  key: _verifyFormKey,
                  child: Card(
                    elevation: 6,
                    color: Constant.scaffoldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: reusableTextFormField(
                        controller: _codeController,
                        hint: "Enter 6-digit code",
                        prefixIcon: Icon(
                          Icons.pin,
                          color: Colors.teal.shade700,
                        ),
                        textInputType: TextInputType.number,
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'code is required';
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'verify code must consist of 6 digits';
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
                      if (_verifyFormKey.currentState!.validate()) {
                        manager.verifyCode({
                          'email': email,
                          'code': _codeController.text,
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
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPassword(),
                      ),
                      (route) => false,
                    );
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
                        content: "Use another email",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
