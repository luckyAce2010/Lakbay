import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDetailsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    // Access Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Replace "user-details" with your Firestore collection name
    // Replace "userUid" with the actual user ID from authentication
    DocumentSnapshot userSnapshot =
        await firestore.collection('user-details').doc('userUid').get();

    // Check if the document exists and contains the contact_list field
    if (userSnapshot.exists && userSnapshot.data() != null) {
      // Access the user details map
      Map<String, dynamic>? userDetails =
          userSnapshot.data() as Map<String, dynamic>?;

      // Check if the user details map is not null and contains the contact_list field
      if (userDetails != null && userDetails['contact_list'] != null) {
        // Access the contact_list field and cast it to a List<Map<String, dynamic>>
        List<Map<String, dynamic>> contactList =
            List<Map<String, dynamic>>.from(userDetails['contact_list']);
        return contactList;
      } else {
        // Return an empty list if the contact_list field doesn't exist
        return [];
      }
    } else {
      // Return an empty list if the document doesn't exist
      return [];
    }
  },
);
