import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/utility/constant.dart';

class CoffeeStateManagement with ChangeNotifier {
  List<CoffeeRecordsModel> items = [];

  // Firestore instance and reference to the 'coffee_records' collection.
  // The collection doesn't need to be created manually in the console —
  // Firestore auto-creates it the first time a document is added to it.
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late final CollectionReference coffeeRecordsRef =
      db.collection(FirebaseConstant.coffeeRecordsCollection);

  // ---------- Existing local-only methods (kept as-is, used by the old screen) ----------

  void addData() {
    items.add(
      CoffeeRecordsModel(
        id: DateTime.now().microsecondsSinceEpoch,
        title: "Coffee Record ${items.length + 1}",
        des: "Details about Coffee Record ${items.length + 1}",
        amount: 10.0,
        date: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void addCoffeeRecord(CoffeeRecordsModel coffeeRecord) {
    items.add(
      CoffeeRecordsModel(
        id: DateTime.now().microsecondsSinceEpoch,
        title: coffeeRecord.title,
        des: coffeeRecord.des,
        amount: coffeeRecord.amount,
        date: coffeeRecord.date,
      ),
    );
    notifyListeners();
  }

    
  
  // ---------- New Firestore methods ----------

  // Sends a CoffeeRecordsModel to Firestore.
  // Step 1: add the document (Firestore auto-generates its ID).
  // Step 2: Firestore hands back a DocumentReference in the response,
  //         whose .id is that auto-generated ID.
  // Step 3: update the same document so its own 'doc_id' field matches
  //         its real Firestore document ID (matches what was shown in class).
  Future<void> sendCoffeeRecordToFirebase(CoffeeRecordsModel coffeeRecord) async {
    DocumentReference response = await coffeeRecordsRef.add(coffeeRecord.toJson());
    await response.update({"doc_id": response.id});
    notifyListeners();
  }

  // Exposes a real-time stream of the 'coffee_records' collection.
  // The new screen will feed this directly into a StreamBuilder.
  Stream<QuerySnapshot> getCoffeeRecordsStream() {
  return coffeeRecordsRef.orderBy('date').snapshots();
  }
}