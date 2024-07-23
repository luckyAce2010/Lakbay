// ignore_for_file: file_names, use_build_context_synchronously, empty_catches, unused_local_variable, invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:lakbay/pages/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/state-notifiers/getContactListNotifier.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Inside ContactList class
class ContactListPage extends ConsumerWidget {
  const ContactListPage({super.key});

  void printEmergencyContacts(List<EmergencyContact> emergencyContacts) {
    final listOfMaps =
        emergencyContacts.map((contact) => contact.toMap()).toList();

    // DatabaseService.saveUserContacts(listOfMaps);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EmergencyContact> emergencyContacts = ref.watch(contactProvider);

    return Scaffold(
      backgroundColor: AppColors.accentWhiteColor,
      body: Consumer(builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: ListView(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OnboardHeader(
                      'emergency list', AppColors.accentDarkGreenColor),
                  SizedBox(height: 15),
                  Text(
                    'Please input the contact details in case of Emergency',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: AppColors.accentBlackColor,
                    ),
                  ),
                  SizedBox(height: 25),
                ],
              ),
              const Column(
                children: [
                  EmergencyContactBox(contactIndex: 0),
                  SizedBox(height: 15),
                ],
              ),
              for (int contactIndex = 1;
                  contactIndex < emergencyContacts.length;
                  contactIndex++)
                Column(children: [
                  EmergencyContactBox(contactIndex: contactIndex),
                  const SizedBox(height: 15),
                ]),
              TextButton(
                onPressed: () {
                  ref.read(contactProvider.notifier).addContact(
                        EmergencyContact(
                          contactName: '',
                          contactNumber: '',
                          contactRelationship: '',
                        ),
                      );
                },
                child: const Text(
                  'Add Another Contact',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentBlackColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Consumer(builder: (context, ref, child) {
          return GestureDetector(
            onTap: () async {
              bool isContactEmpty(EmergencyContact contact) {
                return contact.contactName.trim().isEmpty &&
                    contact.contactNumber.trim().isEmpty &&
                    contact.contactRelationship.trim().isEmpty;
              }

              // Access the state of EmergencyContactForm
              final emergencyContacts = ref.read(contactProvider);

              // Filter out EmergencyContact objects with all values as empty strings
              final filteredContacts = emergencyContacts
                  .where((contact) => !isContactEmpty(contact))
                  .toList();

              // Update the state with filtered contacts
              // ignore: invalid_use_of_protected_member
              ref.read(contactProvider.notifier).state = filteredContacts;

              // Print the filtered contacts or perform other actions
              // Print the filtered contacts or perform other actions
              if (filteredContacts.isNotEmpty) {
                final mappedContacts =
                    filteredContacts.map((contact) => contact.toMap()).toList();

                // Save the contacts to Firestore
                await _DatabaseService.saveUserContacts(
                    mappedContacts.cast<Map<String, String>>());

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              } else {
                // No contacts added, you can show a message or take other action
                ref.read(contactProvider.notifier).addContact(
                      EmergencyContact(
                        contactName: '',
                        contactNumber: '',
                        contactRelationship: '',
                      ),
                    );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accentDarkGreenColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: double.infinity,
                child: const Text('Continue',
                    style: TextStyle(
                        color: AppColors.accentWhiteColor,
                        fontFamily: 'Poppins'),
                    textAlign: TextAlign.center),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class EmergencyContactBox extends StatelessWidget {
  final int contactIndex;

  const EmergencyContactBox({super.key, required this.contactIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      decoration: BoxDecoration(
        color: AppColors.accentSmokeGreenColor,
        border: Border.all(color: AppColors.accentLightGreenColor, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitleText(
              'Contact #${contactIndex + 1}', AppColors.accentBlackColor),
          EmergencyContactFormFields(contactIndex: contactIndex),
        ],
      ),
    );
  }
}

class EmergencyContactFormFields extends StatelessWidget {
  final int contactIndex;

  const EmergencyContactFormFields({super.key, required this.contactIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final List<EmergencyContact> emergencyContacts =
            ref.read(contactProvider);

        return Column(
          children: [
            TextField(
              textAlignVertical:
                  TextAlignVertical.bottom, // Align text to the bottom
              onChanged: (value) {
                emergencyContacts[contactIndex].contactName = value;
              },
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                focusColor: AppColors.accentBlackColor,
                hintText: 'Contact Name',
                hoverColor: AppColors.accentDarkGreenColor,
                fillColor: AppColors.accentDarkGreenColor,
              ),
            ),
            TextField(
              textAlignVertical:
                  TextAlignVertical.bottom, // Align text to the bottom
              onChanged: (value) {
                emergencyContacts[contactIndex].contactNumber = value;
              },
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                focusColor: AppColors.accentBlackColor,
                hintText: 'Contact Number',
                hoverColor: AppColors.accentDarkGreenColor,
                fillColor: AppColors.accentDarkGreenColor,
              ),
            ),
            TextField(
              textAlignVertical:
                  TextAlignVertical.bottom, // Align text to the bottom
              onChanged: (value) {
                emergencyContacts[contactIndex].contactRelationship = value;
              },
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                focusColor: AppColors.accentBlackColor,
                hintText: 'Relationship to the User',
                hoverColor: AppColors.accentDarkGreenColor,
                fillColor: AppColors.accentDarkGreenColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DatabaseService {
  static final CollectionReference _userDetailsRef =
      FirebaseFirestore.instance.collection('user-details');

  static Future<void> saveUserContacts(
      List<Map<String, String>> contacts) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Reference to the user's document in the "user-details" collection
        DocumentReference userDocumentRef = _userDetailsRef.doc(userId);

        // Update the 'contact_list' field in the document
        await userDocumentRef
            .set({'contact_list': contacts}, SetOptions(merge: true));
      }
    } catch (error) {}
  }
}
