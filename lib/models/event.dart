import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/models/service.dart';
import 'package:flutter/material.dart';

import 'hired_service.dart';

class Event {
  String? id;
  String? customerId;
  String? title;
  DateTime? dateTime;
  String? venue;
  List<HiredService>? hiredServices;
  

  Event(
      {this.id,
      this.customerId,
      this.title,
      this.dateTime,
      this.venue,
      this.hiredServices});

  Event.fromFirestore(Map<String, dynamic> map, String eId) {
    id = eId;
    customerId = map['customerId'] as String?;
    title = map['title'] as String?;
    venue = map['venue'] as String?;
    dateTime = DateTime.fromMillisecondsSinceEpoch(
        (map['dateTime'] as Timestamp).millisecondsSinceEpoch);
    venue = map['venue'] as String?;
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
        'venue': venue,
        'hiredServices': hiredServices,
      };

  @override
  bool operator ==(other) =>
      other is Event &&
      customerId == other.customerId &&
      title == other.title &&
      dateTime == other.dateTime &&
      venue == other.venue &&
      hiredServices == other.hiredServices;

  @override
  int get hashCode => hashValues(
        customerId,
        title,
        dateTime,
        venue,
        hashList(hiredServices),
      );
}
