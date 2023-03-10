import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeFactor: 1.2,
              ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color.fromARGB(255, 86, 85, 85),
          )),
      title: 'Flutter connect to Firebase',
      home: const HomePage(),
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final CollectionReference _students =
      FirebaseFirestore.instance.collection('students');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mon Hoc'),
        ),
        // Using StreamBuilder to display all products from Firestore in real-time
        body: StreamBuilder(
          stream: _students.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'id: ${documentSnapshot['name']}',
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text('Ma Mon Hoc: ${documentSnapshot['age']}'),
                              const SizedBox(
                                height: 5,
                              ),
                              Text('Ten Mon Hoc: ${documentSnapshot['email']}'),
                              const SizedBox(
                                height: 5,
                              ),
                              Text('Mo Ta: ${documentSnapshot['address']}'),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Press this button to edit a single product
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _createOrUpdate(documentSnapshot)),
                              // This icon button is used to delete a single product
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(
                                      documentSnapshot.id,
                                      documentSnapshot['name'],
                                      documentSnapshot['age'])),
                            ],
                          ),
                        ],
                      ));
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        // Add new product
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createOrUpdate(),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  // [DocumentSnapshot? documentSnapshot] is optional positional parameters its should be last position
  // when functions have >= 2 parameters.

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _emailController.text = documentSnapshot['email'];
      _addressController.text = documentSnapshot['address'];
      _ageController.text = documentSnapshot['age'].toString();
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
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'id'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your id';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Ma Mon Hoc',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Ma Mon Hoc';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(labelText: 'Ten Moc Hoc'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Ten Mon Hoc';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Mo Ta'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Mo Ta';
                            }
                            return null;
                          },
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String email = _emailController.text;
                    final String address = _addressController.text;
                    final int? age = int.tryParse(_ageController.text);
                    if (_formKey.currentState!.validate()) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _students.add({
                          "name": name,
                          "age": age,
                          "email": email,
                          "address": address
                        });
                      }

                      if (action == 'update') {
                        // Update the product
                        await _students.doc(documentSnapshot!.id).update({
                          "name": name,
                          "age": age,
                          "email": email,
                          "address": address
                        });
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _ageController.text = '';
                      _emailController.text = '';
                      _addressController.text = '';

                      // Hide the bottom sheet
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            '${action == 'create' ? 'Create' : 'Update'} information successfully',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 255, 8),
                                fontSize: 18),
                          )));
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(
      String productId, String nameUser, int age) async {
    await showDialog(
        context: context,
        // Can't GestureDetector outside dialog
        barrierDismissible: false,
        builder: (builder) => AlertDialog(
              actions: [
                TextButton(
                  child: const Text('Oke'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    _students.doc(productId).delete();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        elevation: 20,
                        duration: Duration(seconds: 2),
                        content: Text(
                          'Deleted information successfully',
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 255, 8),
                              fontSize: 18),
                        )));
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
              content: Text("Name: $nameUser, Age: $age"),
              title: const Text('Do you want to delete this mon hoc?'),
            ));

    // Show a snackbar
  }
}
