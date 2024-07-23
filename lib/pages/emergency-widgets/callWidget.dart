import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:url_launcher/url_launcher.dart';

class CallRow extends StatelessWidget {
  final String contactName;
  final String contactNumber;

  CallRow({required this.contactName, required this.contactNumber});

  void _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: contactNumber);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle error, e.g., show a snackbar
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
            icon: const Icon(Icons.call),
            onPressed: _makeCall,
            color: AppColors.accentDarkGreenColor,
          ),
        ],
      ),
    );
  }
}