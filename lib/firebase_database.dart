import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL:
        'https://lakbay-7dffa-default-rtdb.asia-southeast1.firebasedatabase.app/');
