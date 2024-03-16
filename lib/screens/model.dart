import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class user{
  final String? id;
  final String fname;
  final String lname;
  user({
this.id,required this.fname,required this.lname,});


factory user.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> document) {
  final data = document.data()!;
  return user(
    id: document.id,
    fname: data['firstname'] ?? '',
    lname: data['lname'] ?? '',
  );
}
}