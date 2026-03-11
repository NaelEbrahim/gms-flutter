import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';

Widget reusableText({
  required String content,
  double fontSize = 12.0,
  int maxLines = 1,
  FontWeight fontWeight = FontWeight.normal,
  Color fontColor = Colors.white,
  TextAlign textAlign = TextAlign.center,
}) => Text(
  content,
  textAlign: textAlign,
  maxLines: maxLines,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    color: fontColor,
    fontSize: fontSize,
    fontWeight: fontWeight,
  ),
);

Widget reusableTextFormField({
  required String hint,
  required Icon prefixIcon,
  required TextEditingController controller,
  IconData? suffixIcon,
  void Function()? suffixIconFunction,
  bool obscureText = false,
  double radius = 0.0,
  Color fontColor = Colors.white,
  Color focusedColor = Colors.greenAccent,
  int maxLines = 1,
  TextInputType textInputType = TextInputType.text,
  String? Function(String?)? validator,
  bool readOnly = false,
  TextInputAction textInputAction = TextInputAction.next,
  void Function()? onTap,
  Widget Function(BuildContext context, EditableTextState editableTextState)?
  contextMenuBuilder,
}) => TextFormField(
  controller: controller,
  obscureText: obscureText,
  keyboardType: textInputType,
  maxLines: maxLines,
  readOnly: readOnly,
  textInputAction: textInputAction,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  onTap: onTap,
  style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.black54,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.white54),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: focusedColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.red),
    ),
    errorMaxLines: 3,
    prefixIcon: prefixIcon,
    suffixIcon: (suffixIcon != null)
        ? IconButton(onPressed: suffixIconFunction, icon: Icon(suffixIcon))
        : null,
    hintText: hint,
    prefixIconColor: Colors.greenAccent,
    suffixIconColor: Colors.greenAccent,
  ),
  contextMenuBuilder: contextMenuBuilder,
  validator: (validator == null)
      ? (value) {
          if (value!.isEmpty) {
            return 'must\'t be empty';
          }
          return null;
        }
      : validator,
);

Widget reusableTextButton({
  required String text,
  required Function() function,
  double height = 20.0,
  double width = 50.0,
  Color textColor = Colors.white,
  double fontSize = 20.0,
  FontWeight fontWeight = FontWeight.bold,
}) => GestureDetector(
  onTap: function,
  child: Container(
    alignment: Alignment.center,
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: Colors.teal,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
      ),
    ),
  ),
);

class ReusableComponents {
  static void showToast(String message, {Color background = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: background,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static String formatDateTime(
    String dateTimeString, {
    String format = 'yyyy/MM/dd HH:mm',
  }) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatted = DateFormat(format).format(dateTime);
    return formatted;
  }

  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteDialog<T extends Cubit<BLoCStates>>(
    BuildContext context,
    Future<void> Function() onDelete, {
    String? title,
    String? body,
  }) async {
    final bloc = BlocProvider.of<T>(context);

    await showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<T, BLoCStates>(
            listener: (context, state) {
              if (state is SuccessState) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: AlertDialog(
              backgroundColor: const Color(0xff2b2b2b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                title ?? 'Confirm delete?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                body ?? 'Are you sure you want to delete this item?',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                BlocBuilder<T, BLoCStates>(
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return const CircularProgressIndicator();
                    }
                    return TextButton(
                      onPressed: () => onDelete(),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool> saveImageToGallery(String pathOrUrl) async {
    final isGranted = await _requestStoragePermission();
    if (!isGranted) {
      showToast("Permission denied");
      return false;
    }
    try {
      if (pathOrUrl.startsWith('http')) {
        await GallerySaver.saveImage(pathOrUrl, albumName: "ShapeUp");
      } else {
        await GallerySaver.saveImage(
          File(pathOrUrl).path,
          albumName: "ShapeUp",
        );
      }
      showToast("Image saved to gallery", background: Colors.green);
      return true;
    } catch (e) {
      showToast("Failed to save image");
      return false;
    }
  }

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      // Android 13+
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android 9–12
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return false;
  }
}