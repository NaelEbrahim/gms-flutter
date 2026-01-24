import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:image_picker/image_picker.dart';

import '../../BLoC/Manager.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  String firstName = SharedPrefHelper.getString('firstName').toString();
  String lastName = SharedPrefHelper.getString('lastName').toString();
  String email = SharedPrefHelper.getString('email').toString();
  String phoneNumber = SharedPrefHelper.getString('phoneNumber').toString();
  String gender = SharedPrefHelper.getString('gender').toString();
  String dob = SharedPrefHelper.getString('dob').toString();
  String profileImage = SharedPrefHelper.getString(
    'profileImagePath',
  ).toString();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) => SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: Constant.screenHeight * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Constant.scaffoldColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.teal.withOpacity(0.15),
                        child: ClipOval(
                          child: (profileImage != 'null')
                              ? Image.network(
                                  Constant.mediaURL + profileImage,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    FontAwesomeIcons.circleUser,
                                    color: Colors.teal.shade700,
                                    size: 80,
                                  ),
                                )
                              : Icon(
                                  FontAwesomeIcons.circleUser,
                                  color: Colors.teal.shade700,
                                  size: 80,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: InkWell(
                          onTap: () async {
                            final XFile? image = await ReusableComponents.pickImage();
                            if (image != null) {
                              Manager.get(context).updateProfileImage(image);
                            }
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.greenAccent,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  reusableText(
                    content: "$firstName $lastName",
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    fontColor: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  reusableText(
                    content: email,
                    fontSize: 15.0,
                    fontColor: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                infoCard("Phone Number", phoneNumber, Icons.phone),
                infoCard("Gender", gender, Icons.person),
                infoCard("Date of Birth", dob, Icons.cake),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    _showEditProfile(context, Manager.get(context));
                  },
                  child: Container(
                    width: Constant.screenWidth / 2,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Constant.scaffoldColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit, color: Colors.white),
                        const SizedBox(width: 10.0),
                        reusableText(
                          content: 'Edit Profile',
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.greenAccent.withAlpha(51),
            child: Icon(icon, color: Colors.greenAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reusableText(
                  content: title,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  fontColor: Colors.white,
                ),
                const SizedBox(height: 4),
                reusableText(
                  content: value,
                  fontSize: 16.0,
                  fontColor: Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, Manager manager) {
    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phoneNumber);
    final genderController = TextEditingController(text: gender);
    final dobController = TextEditingController(text: dob);

    showModalBottomSheet(
      context: context,
      backgroundColor: Constant.scaffoldColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BlocProvider.value(
        value: manager,
        child: BlocConsumer<Manager, BLoCStates>(
          listener: (context, state) {},
          builder: (context, state) {
            // Get current values from manager state
            String selectedGender = gender;
            String selectedDob = dob;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    reusableText(
                      content: 'Edit Profile',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "First Name",
                      icon: Icons.person,
                      controller: firstNameController,
                    ),
                    _buildTextField(
                      label: "Last Name",
                      icon: Icons.badge_outlined,
                      controller: lastNameController,
                    ),
                    _buildTextField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      label: "Phone Number",
                      icon: Icons.phone,
                      controller: phoneController,
                      textInputType: TextInputType.phone,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.male_outlined,
                            color: Colors.greenAccent,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Colors.greenAccent,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.black54,
                        ),
                        dropdownColor: Colors.black87,
                        items: ["Male", "Female"]
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: reusableText(
                                  content: g,
                                  fontColor: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            gender = value;
                            genderController.text = gender;
                            manager.updateState();
                          }
                        },
                      ),
                    ),
                    reusableTextFormField(
                      hint: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      controller: TextEditingController(text: selectedDob),
                      readOnly: true,
                      radius: 12.0,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(selectedDob) ?? DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          dob =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          dobController.text = dob;
                          manager.updateState();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ConditionalBuilder(
                      condition: state is! LoadingState,
                      builder: (context) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          firstName = firstNameController.text;
                          lastName = lastNameController.text;
                          email = emailController.text;
                          phoneNumber = phoneController.text;
                          manager.updateProfile({
                            'firstName': firstNameController.text,
                            'lastName': lastNameController.text,
                            'email': emailController.text,
                            'phoneNumber': phoneController.text,
                            'dob': dobController.text,
                            'gender': genderController.text,
                          });
                        },
                        child: reusableText(
                          content: 'Save',
                          fontColor: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType textInputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: reusableTextFormField(
        hint: label,
        radius: 12,
        prefixIcon: Icon(icon),
        controller: controller,
        textInputType: textInputType,
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar(
            anchors: editableTextState.contextMenuAnchors,
            children: [
              TextSelectionToolbarTextButton(
                padding: const EdgeInsets.all(8.0),
                onPressed: () {
                  editableTextState.copySelection(
                    SelectionChangedCause.toolbar,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Copy'),
              ),
              TextSelectionToolbarTextButton(
                padding: const EdgeInsets.all(8.0),
                onPressed: () {
                  editableTextState.selectAll(SelectionChangedCause.toolbar);
                  Navigator.pop(context);
                },
                child: const Text('Select All'),
              ),
            ],
          );
        },
      ),
    );
  }
}
