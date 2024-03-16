import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

import 'package:trace_app_3c/screens/establishmentprofile.dart';
import 'package:trace_app_3c/screens/home.dart';

class EstablishmentScreen extends StatefulWidget {
   EstablishmentScreen({Key? key,required this.userId}) : super(key: key);
final userId;
  @override
  _EstablishmentScreenState createState() => _EstablishmentScreenState();
}

class _EstablishmentScreenState extends State<EstablishmentScreen> {
  final collectionPath = "logs";
  late DateTime selectedDate = DateTime.now(); // Initialize selectedDate

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  void scanQR(BuildContext context) async {
    // Scan the QR code
    String result = await FlutterBarcodeScanner.scanBarcode(
      '#ffffff', 'CANCEL', true, ScanMode.DEFAULT);

    if (result != '-1') {
      // Retrieve user data from Firestore based on the scanned QR code
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(result)
          .get();

      if (userSnapshot.exists) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: 'Loading',
          text: 'Saving to logs',
        );
        // The scanned QR code is valid
        // Proceed with logging the visit
      
        await FirebaseFirestore.instance.collection(collectionPath).add({
          'client_uid': result,
          'establishment_uid': FirebaseAuth.instance.currentUser!.uid,
          'datetime': DateTime.now(),
        });
        Navigator.of(context).pop();

      } else {
        // The scanned QR code is not registered
        // Show an appropriate message to the user
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid QR Code'),
              content: Text('The scanned QR code is not registered.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 50),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then((DocumentSnapshot document) {
                      if (document.exists) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileEstablishmentScreen(establishment_uid: widget.userId)),
                        );
                      } else {
                        print('No such document!');
                      }
                    }).catchError((error) {
                      print('Error getting document: $error');
                    });
              },
              child: Text("Profile"),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Establishment'),
        actions: [
          IconButton(
            onPressed: () => signOut(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => scanQR(context),
                child: const Text('Scan'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text('Select Date'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                .collection(collectionPath)
                .where('establishment_uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)

                .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text('No data available'),
                  );
                }
                final documents = snapshot.data!.docs;
                return FilteredDataWidget(documents: documents, selectedDate: selectedDate);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilteredDataWidget extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final DateTime selectedDate;

  const FilteredDataWidget({
    Key? key,
    required this.documents,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = documents.where((document) {
      final Timestamp dateTimeStamp = document['datetime'];
      final DateTime dateTime = dateTimeStamp.toDate();
      final DateTime documentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final DateTime selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      return documentDate.isAtSameMomentAs(selectedDateTime);
    }).toList();

    return ListView.builder(
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final DocumentSnapshot document = filteredDocuments[index];
        final Map<String, dynamic>? data = document.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
        if (data != null && data.containsKey('client_uid')) {
          return ListTile(
            title: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['client_uid'])
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final userData = snapshot.data!.data()!;
                return Row(
                  children: [
                    Text(userData['firstname']),
                    SizedBox(width: 10),
                    Text(userData['lastname']),
                  ],
                );
              },
            ),
            subtitle: Text(_formatDateTime(document['datetime'] as Timestamp)),
          );
        } else {
          return Container();
        }
      },
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
