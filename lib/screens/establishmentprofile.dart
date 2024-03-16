import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

class ProfileEstablishmentScreen extends StatefulWidget {
  const ProfileEstablishmentScreen({Key? key, required this.establishment_uid})
      : super(key: key);

  final String establishment_uid;

  @override
  _ProfileEstablishmentScreenState createState() =>
      _ProfileEstablishmentScreenState();
}

class _ProfileEstablishmentScreenState
    extends State<ProfileEstablishmentScreen> {
  late final TextEditingController businessName;
  late final TextEditingController contactPersonName;
  late final TextEditingController address;
late String establishmentType = '';

  @override
  void initState() {
    super.initState();
    businessName = TextEditingController();
    contactPersonName = TextEditingController();
    address = TextEditingController();

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.establishment_uid)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('type') && data['type'] == 'establishment') {
          setState(() {
            establishmentType = data['type'];
            businessName.text = data['businessName'];
            contactPersonName.text = data['personcontactName'];
            address.text = data['address'];
          });
       
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Establishment not found'),
            ),
          );
        }
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching establishment data: $error'),
        ),
      );
    });
  }

  @override
  void dispose() {
    businessName.dispose();
    contactPersonName.dispose();
    address.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.establishment_uid)
        .update({
      'businessName': businessName.text,
      'contactPersonName': contactPersonName.text,
      'address': address.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
        ),
      );
    });
  }

  InputDecoration setTextDecoration(String name) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      label: Text(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Establishment Type: $establishmentType'),
            const Gap(20),
            TextFormField(
              controller: businessName,
              decoration: setTextDecoration('Business Name'),
            ),
            const Gap(20),
            TextFormField(
              controller: contactPersonName,
              decoration: setTextDecoration('Contact Person Name'),
            ),
            const Gap(20),
            TextFormField(
              controller: address,
              decoration: setTextDecoration('Address'),
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
