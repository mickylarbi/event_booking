import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  double? rating;
  String? userId;
  String? comment;
  DateTime? dateTime;

  Review({this.rating, this.userId, this.comment, this.dateTime});

  Review.fromMap(
    Map<String, dynamic> map,
  ) {
    rating = map['rating'];
    userId = map['userId'];
    comment = map['comment'];
    dateTime = DateTime.fromMillisecondsSinceEpoch(
        (map['dateTime'] as Timestamp).millisecondsSinceEpoch);
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'userId': userId,
      'comment': comment,
      'dateTime': dateTime
    };
  }
}

double calculateRating(List<Review>? reviewList) {
  if (reviewList == null || reviewList.isEmpty) return 0.0;

  double? sum = 0;

  for (Review review in reviewList) {
    sum = review.rating;
  }

  return (sum! / reviewList.length);
}
