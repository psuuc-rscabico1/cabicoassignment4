import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trace_app_3c/screens/clientprofile.dart';
import 'package:trace_app_3c/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientScreen extends StatelessWidget {
  final String userId;

  ClientScreen({Key? key, required this.userId});

  void signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Future<List<Map<String, dynamic>>> fetchVisitHistory(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('logs')
          .where('client_uid', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (error) {
      print('Error fetching visit history: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 100,),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)));
              },
              child: Text("Profile"),
            ),
            TextButton(
              onPressed: () async {
                final visitHistory = await fetchVisitHistory(userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VisitHistoryScreen(visitHistory: visitHistory)),
                );
              },
              child: Text("View Visit History"),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Client'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => signout(context),
            icon: FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
            ),
          ),
        ],
      ),
      body: Center(
        child: QrImageView(
          data: userId,
          version: QrVersions.auto,
        ),
      ),
    );
  }
}



class VisitHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> visitHistory;

  VisitHistoryScreen({Key? key, required this.visitHistory}) : super(key: key);

  @override
  _VisitHistoryScreenState createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }
Future<String> fetchBusinessName(String establishmentId) async {
  try {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('users') // Assuming 'establishment' is a type stored in the 'users' collection
        .doc(establishmentId)
        .get();

    print('Document Snapshot: $documentSnapshot'); // Add this line for debugging

    final businessName = documentSnapshot['businessName'];
    return businessName ?? 'Unknown Business';
  } catch (error) {
    print('Error fetching business name: $error');
    return 'Unknown Business';
  }
}




  @override
  Widget build(BuildContext context) {
    // Filter the visit history based on the selected date
    List<Map<String, dynamic>> filteredHistory = widget.visitHistory.where((visit) {
      final timestamp = visit['datetime'] as Timestamp;
      final visitDate = timestamp.toDate();
      return visitDate.year == selectedDate.year &&
          visitDate.month == selectedDate.month &&
          visitDate.day == selectedDate.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Visit History'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Selected Date: ${DateFormat('EEEE, MMM d, y').format(selectedDate)}'),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                final pickedDate = await showDatePicker(
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
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
  itemCount: filteredHistory.length,
  itemBuilder: (context, index) {
    final visitData = filteredHistory[index];
    final timestamp = visitData['datetime'] as Timestamp;
    final visitDate = timestamp.toDate();
    final formattedDate = DateFormat('EEEE, MMM d, y').format(visitDate);

    return FutureBuilder<String>(
      future: fetchBusinessName(visitData['establishment_uid']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Loading...'),
            subtitle: Text('Visit Date: $formattedDate'),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Error Loading Business Name'),
            subtitle: Text('Visit Date: $formattedDate'),
          );
        }
        final businessName = snapshot.data ?? 'Unknown Business';
        return ListTile(
          title: Text('Business Name: $businessName'),
          subtitle: Text('Visit Date: $formattedDate'),
        );
      },
    );
  },
),

          ),
        ],
      ),
    );
  }
}
