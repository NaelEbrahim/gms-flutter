import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gms_flutter/Shared/Components.dart';
import '../../Shared/SharedPrefHelper.dart';

class ShowQR extends StatelessWidget {
  ShowQR({super.key});

  final String myQrData = SharedPrefHelper.getString('id') ?? 'NO_DATA_FOUND';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          reusableText(
            content: 'Ready to Scan',
            fontColor: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 35.0),
          Container(
            width: Constant.screenWidth * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade700.withAlpha(76),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(35.0, 35.0, 35.0, 20.0),
                  child: Column(
                    children: [
                      QrImageView(
                        data: myQrData,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                        size: Constant.screenWidth * 0.55,
                        embeddedImage: const AssetImage('images/logo.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(55, 55),
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                        gapless: true,
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.idCard,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 5),
                          reusableText(
                            content: 'Card ID: $myQrData',
                            fontWeight: FontWeight.normal,
                            fontColor: Colors.black54,
                            fontSize: 13.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sensor_door_outlined,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      reusableText(
                        content: 'Scan this code at the gym gate',
                        fontWeight: FontWeight.bold,
                        fontColor: Colors.white,
                        fontSize: 15.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
