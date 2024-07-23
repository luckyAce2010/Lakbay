// ignore_for_file: file_names

import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactProvider = StateNotifierProvider<ContactNotifier, List<EmergencyContact>>(
  (ref) => ContactNotifier([EmergencyContact(contactName: '', contactNumber: '', contactRelationship: '')]),
);

class ContactNotifier extends StateNotifier<List<EmergencyContact>> {
  ContactNotifier(List<EmergencyContact> state) : super(state);

  void addContact(EmergencyContact contact) {
    state = [...state, contact];
  }

  List<Map<String, String>> toListOfMaps() {
    return state.map((contact) => contact.toMap()).toList();
  }
}

class EmergencyContact {
  String contactName;
  String contactNumber;
  String contactRelationship;

  EmergencyContact({
    required this.contactName,
    required this.contactNumber,
    required this.contactRelationship,
  });

  Map<String, String> toMap() {
    return {
      'contact_name': contactName,
      'contact_number': contactNumber,
      'contact_relationship': contactRelationship,
    };
  }
}