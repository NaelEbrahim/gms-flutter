import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:image_picker/image_picker.dart';

import '../../BLoC/Manager.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Manager manager;

  final firstNameController = TextEditingController(
    text: SharedPrefHelper.getString('firstName') ?? '',
  );
  final lastNameController = TextEditingController(
    text: SharedPrefHelper.getString('lastName') ?? '',
  );
  final emailController = TextEditingController(
    text: SharedPrefHelper.getString('email') ?? '',
  );
  final phoneController = TextEditingController(
    text: SharedPrefHelper.getString('phoneNumber') ?? '',
  );
  final genderController = TextEditingController(
    text: SharedPrefHelper.getString('gender') ?? '',
  );
  final dobController = TextEditingController(
    text: SharedPrefHelper.getString('dob') ?? '',
  );

  String? get profileImage => SharedPrefHelper.getString('profileImagePath');

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) => Scaffold(
        backgroundColor: Constant.scaffoldColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: reusableText(
            content: 'Profile',
            fontSize: 22.0,
            fontColor: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConditionalBuilder(
              condition: state is! LoadingState,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      height: Constant.screenHeight * 0.35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade700,
                            Constant.scaffoldColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(76),
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
                                backgroundColor: Colors.teal.withAlpha(76),
                                child: ClipOval(
                                  child: (profileImage != null)
                                      ? Image.network(
                                          Constant.mediaURL +
                                              profileImage.toString(),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Icon(
                                            FontAwesomeIcons.circleUser,
                                            color: Colors.greenAccent,
                                            size: 80,
                                          ),
                                        )
                                      : Icon(
                                          FontAwesomeIcons.circleUser,
                                          color: Colors.greenAccent,
                                          size: 80,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: InkWell(
                                  onTap: () async {
                                    final XFile? image =
                                        await ReusableComponents.pickImage();
                                    if (image != null) {
                                      FormData formData = FormData.fromMap({
                                        'id': SharedPrefHelper.getString(
                                          'id',
                                        ).toString(),
                                        'image': await MultipartFile.fromFile(
                                          image.path,
                                          filename: image.name,
                                        ),
                                      });
                                      manager.updateProfileImage(formData);
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
                            content:
                                "${firstNameController.text} ${lastNameController.text}",
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            fontColor: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          reusableText(
                            content: emailController.text,
                            fontSize: 15.0,
                            fontColor: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    infoCard("Phone Number", phoneController.text, Icons.phone),
                    infoCard("Gender", genderController.text, Icons.person),
                    infoCard("Date of Birth", dobController.text, Icons.cake),
                    const SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () {
                        _showEditProfile(context);
                      },
                      child: Container(
                        width: Constant.screenWidth / 2,
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade700,
                              Constant.scaffoldColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(76),
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
              ),
              fallback: (context) =>
                  Center(child: const CircularProgressIndicator()),
            ),
          ),
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

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Constant.scaffoldColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dialogContext) => Padding(
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
                  initialValue: genderController.text,
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
                      borderSide: const BorderSide(color: Colors.greenAccent),
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
                      genderController.text = value;
                    }
                  },
                ),
              ),
              reusableTextFormField(
                hint: 'Date of Birth',
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                controller: dobController,
                readOnly: true,
                radius: 12.0,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(dobController.text) ?? DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dobController.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                  manager.updateProfile({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'phoneNumber': phoneController.text,
                    'dob': dobController.text,
                    'gender': genderController.text,
                  });
                  Navigator.pop(context);
                },
                child: reusableText(
                  content: 'Save',
                  fontColor: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
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
