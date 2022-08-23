import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/models/service.dart';
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
  List<HiredService>? hiredServices;

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
    customerId = map['customerId'] as String?;
    title = map['title'] as String?;
    venueString = map['venue'] as String?;
    dateTime = DateTime.fromMillisecondsSinceEpoch(
        (map['dateTime'] as Timestamp).millisecondsSinceEpoch);
    venueString = map['venueString'] as String?;
    venueGeo = map['venueGeo'];
    hiredServices = map['serviceProviderIds'];
    // List<dynamic>? tempList = map['familyMedicalHistory'] as List<dynamic>?;
    // if (tempList != null) {
    //   serviceProviderIds = [];
    //   for (String element in tempList) {
    //     serviceProviderIds!.add(element);
    //   }
    // }
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'title': title,
        'dateTime': dateTime,
        'venueString': venueString,
        'venueGeo': venueGeo,
        'hiredServices': hiredServices,
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
