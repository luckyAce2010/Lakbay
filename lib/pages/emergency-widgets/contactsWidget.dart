// ignore: file_names
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactRow extends StatelessWidget {
  final String contactName;
  final String contactNumber;
  final String locationData;
  final String latitude;
  final String longitude;

  const ContactRow({super.key, required this.contactName, required this.contactNumber, required this.locationData, required this.latitude, required this.longitude});

  void _sendMessage() async {
    try {
      final String message = "My current location is in: $locationData, Philippines, Latitude: $latitude Longitude: $longitude";

      if (Platform.isAndroid) {
        String uri = 'sms:$contactNumber?body=${Uri.encodeComponent(message)}';
        await launchUrl(Uri.parse(uri));
      } else if (Platform.isIOS) {
        String uri = 'sms:$contactNumber&body=${Uri.encodeComponent(message)}';
        await launchUrl(Uri.parse(uri));
      }
    } catch (e) {
      print(e);
    }
      
  }

  void _makeCall() async {
    String uri = 'tel:$contactNumber';
    
    try {
      await launchUrl(Uri.parse(uri));
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color:const Color.fromARGB(255, 226, 226, 226), width: 2, )
      ),
      child: Row(
        children: [
          NormalText(contactName, AppColors.accentBlackColor),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _sendMessage,
            color: AppColors.accentDarkGreenColor,
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _makeCall,
            color: AppColors.accentDarkGreenColor,
          ),
        ],
      ),
    );
  }
}