import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy_admin/Pages/Homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD9KKVLV97Uj6sKAaBpM8621uwDWL-215w",
      authDomain: "kealthy-90c55.firebaseapp.com",
      projectId: "kealthy-90c55",
      storageBucket: "kealthy-90c55.appspot.com",
      messagingSenderId: "486140167563",
      appId: "1:486140167563:web:688322367985fb85ae5b8e",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Delivery',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}
