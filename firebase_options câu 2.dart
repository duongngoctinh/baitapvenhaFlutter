import 'package:ff123/firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'CRUD LopHoc',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _diaChiController = TextEditingController();
  final TextEditingController _maGiangVienController = TextEditingController();
  final TextEditingController _sdtController = TextEditingController();

  final CollectionReference _giangvien =
      FirebaseFirestore.instance.collection('giangvien');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _hoTenController.text = documentSnapshot['hoten'];
      _diaChiController.text = documentSnapshot['diachi'];
      _maGiangVienController.text = documentSnapshot['magiangvien'].toString();
      _sdtController.text = documentSnapshot['sdt'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _diaChiController,
                  decoration: const InputDecoration(labelText: 'Dia chi:'),
                ),
                TextField(
                  controller: _hoTenController,
                  decoration: const InputDecoration(labelText: 'Ho ten:'),
                ),
                TextField(
                  controller: _maGiangVienController,