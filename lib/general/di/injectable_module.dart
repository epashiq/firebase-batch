import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app_with_firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

@module
abstract class InjectableModule {
  @preResolve
  Future<FirebaseServices> get firebaseServices => FirebaseServices.init();

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
}

class FirebaseServices {
  static Future<FirebaseServices> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    return FirebaseServices();
  }
}
