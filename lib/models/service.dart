import 'package:flutter/material.dart';

class Service {
  String? id;
  String? providerId;
  String? title;
  String? description;
  double? leastPrice;
  double? highestPrice;
  List<String>? imageUrls;

  Service({
    this.id,
    this.providerId,
    this.title,
    this.description,
    this.leastPrice,
    this.highestPrice,
    this.imageUrls,
  });

  Service.fromFirestore(Map<String, dynamic> map, sId) {
    id = sId;
    providerId = map['providerId'];
    title = map['title'];
    description = map['description'];
    leastPrice = map['leastPrice'].toDouble();
    highestPrice = map['highestPrice'].toDouble();
    imageUrls =
        (map['imageUrls'] as List<dynamic>?)!.map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toMap() => {
        'providerId': providerId,
        'title': title,
        'description': description,
        'leastPrice': leastPrice,
        'highestPrice': highestPrice,
        'imageUrls': imageUrls ?? [],
      };

  @override
  bool operator ==(other) =>
      other is Service &&
      other.providerId == providerId &&
      other.title == title &&
      other.description == description &&
      other.leastPrice == leastPrice &&
      other.highestPrice == highestPrice;

  @override
  int get hashCode => hashValues(
        providerId,
        title,
        description,
        leastPrice,
        highestPrice,
      );
}
