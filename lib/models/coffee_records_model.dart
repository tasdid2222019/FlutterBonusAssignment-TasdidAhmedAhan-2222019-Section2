import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeRecordsModel {
  int id;
  String title;
  String des;
  double amount;
  DateTime date;
  String docId;

  CoffeeRecordsModel({
    this.id = 0,
    this.title = '',
    this.des = '',
    this.amount = 0.0,
    DateTime? date,
    this.docId = '',
  }) : date = date ?? DateTime.now();

  // Converts this model into a Map, ready to send to Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "des": des,
      "amount": amount,
      "date": date.toIso8601String(),
      "doc_id": docId,
    };
  }

  // Builds a model from a Firestore document snapshot
  // Handles both a raw JSON string date (e.g. from quicktype-style import)
  // and a Firestore Timestamp (what you'll actually get reading from Firestore)
  factory CoffeeRecordsModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parsedDate = DateTime.now();
    final rawDate = json["date"];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return CoffeeRecordsModel(
      id: json["id"] as int? ?? 0,
      title: json["title"] as String? ?? '',
      des: json["des"] as String? ?? '',
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      docId: docId ?? json["doc_id"] as String? ?? '',
    );
  }

  // Helper: decode a JSON array string into a List<CoffeeRecordsModel>
  static List<CoffeeRecordsModel> decodeCoffeeRecords(String jsonArrayString) {
    final List<dynamic> decodedList = jsonDecode(jsonArrayString);
    return decodedList
        .map((item) => CoffeeRecordsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Helper: encode a List<CoffeeRecordsModel> into a JSON array string
  static String encodeCoffeeRecords(List<CoffeeRecordsModel> records) {
    final List<Map<String, dynamic>> jsonList =
        records.map((record) => record.toJson()).toList();
    return jsonEncode(jsonList);
  }
}