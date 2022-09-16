import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'hired_service.dart';

class Event {
  String? id;
  String? customerId;
  String? title;
  DateTime? dateTime;
  String? venueString;
  LatLng? venueGeo;
  List<String>? hiredServices;

  Event(
      {this.id,
      this.customerId,
      this.title,
      this.dateTime,
      this.venueString,
      this.venueGeo,
      this.hiredServices});

  Event.fromFirestore(Map<String, dynamic> map, String eId) {
    id = eId;
    title = map['title'] as String?;
    dateTime = DateTime.fromMillisecondsSinceEpoch(
        (map['dateTime'] as Timestamp).millisecondsSinceEpoch);
    venueString = map['venueString'] as String?;
    venueGeo = LatLng(map['venueGeo'].latitude, map['venueGeo'].longitude);
    hiredServices = (map['hiredServices'] as List<dynamic>?)!
        .map((e) => e.toString())
        .toList();
  }

  Map<String, dynamic> toMap() => {
        'customerId': FirebaseAuth.instance.currentUser!.uid,
        'title': title,
        'dateTime': dateTime,
        'venueString': venueString,
        'venueGeo': GeoPoint(venueGeo!.latitude, venueGeo!.longitude),
        'hiredServices': hiredServices ?? [],
      };

  @override
  bool operator ==(other) =>
      other is Event &&
      customerId == other.customerId &&
      title == other.title &&
      dateTime == other.dateTime &&
      venueString == other.venueString &&
      venueGeo == other.venueGeo &&
      hiredServices == other.hiredServices;

  @override
  int get hashCode => hashValues(
        customerId,
        title,
        dateTime,
        venueString,
        venueGeo,
        hashList(hiredServices),
      );
}
