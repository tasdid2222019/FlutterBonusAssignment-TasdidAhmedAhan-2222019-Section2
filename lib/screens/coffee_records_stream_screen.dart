import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';
import 'package:summer_iub_app/widgets/app_backgroud_design_widget.dart';

class CoffeeRecordsStreamScreen extends StatefulWidget {
  const CoffeeRecordsStreamScreen({super.key});

  @override
  State<CoffeeRecordsStreamScreen> createState() =>
      _CoffeeRecordsStreamScreenState();
}

class _CoffeeRecordsStreamScreenState extends State<CoffeeRecordsStreamScreen> {
  late CoffeeStateManagement csm;

  @override
  void initState() {
    super.initState();
    csm = Provider.of<CoffeeStateManagement>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Live Coffee Records",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.00,
          ),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: AppBackgroudDesignWidget(
        child: StreamBuilder<QuerySnapshot>(
          stream: csm.getCoffeeRecordsStream(),
          builder: (context, snapshot) {
            // 1. Handle errors from the stream
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong: ${snapshot.error}",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            // 2. Handle the initial loading state, before the first snapshot arrives
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // 3. Handle an empty collection (no documents yet)
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  "No coffee records yet.\nAdd one to see it appear here in real time!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.brown, fontSize: 16.00),
                ),
              );
            }

            // 4. We have data — build the list
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                final CoffeeRecordsModel coffeeRecord =
                    CoffeeRecordsModel.fromJson(data, docId: doc.id);

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.coffee),
                    title: Text(coffeeRecord.title),
                    subtitle: Text(
                      "${coffeeRecord.des} - Amount: ${coffeeRecord.amount} - Doc ID: (${coffeeRecord.docId})",
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(  
        onPressed: () {
          csm.sendCoffeeRecordToFirebase(
            CoffeeRecordsModel(
              id: DateTime.now().microsecondsSinceEpoch,
              title: "New Coffee Record ${csm.items.length + 1}",
              des: "THIS IS A TEST DATA",
              amount: 10.0,
              date: DateTime.now(),
            ),
          );
        },
        child: Icon(Icons.local_cafe),
      ), 
    );
  }
}
    