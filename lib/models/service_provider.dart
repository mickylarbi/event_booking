import 'package:event_booking/models/review.dart';
import 'package:flutter/material.dart';

class ServiceProvider {
  String? id;
  String? name;
  String? motto;
  String? bio;
  List<Review>? reviews;

  ServiceProvider({this.id, this.name, this.bio, this.motto, this.reviews});

  ServiceProvider.fromFirestore(Map<String, dynamic> map, String sId) {
    id = sId;
    name = map['name'];
    motto = map['motto'];
    bio = map['bio'];

    List? tempList = map['reviews'] as List<Map<String, dynamic>>?;
    if (tempList != null) {
      reviews = [];
      for (Map<String, dynamic> element in tempList) {
        reviews!.add(Review.fromMap(element));
      }
    }
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'motto': motto,
        'bio': bio,
        if (reviews != null) 'reviews': reviews!.map((e) => e.toMap()).toList(),
      };

  @override
  bool operator ==(other) =>
      other is ServiceProvider &&
      other.id == id &&
      other.name == name &&
      other.motto == motto &&
      other.bio == bio;

  @override
  int get hashCode => hashValues(id, name, motto, bio);
}
