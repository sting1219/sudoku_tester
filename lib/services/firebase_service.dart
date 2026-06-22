import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<void> uploadUserData(UserData userData) async {
    if (uid == null) return;
    
    await _firestore.collection('users').doc(uid).set(
      userData.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<UserData?> downloadUserData() async {
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserData.fromJson(doc.data()!);
    }
    return null;
  }
}
