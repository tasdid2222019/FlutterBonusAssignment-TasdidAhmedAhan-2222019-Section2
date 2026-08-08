class CoffeeRecordsModel {
  final int id;
  final String title;
  final String des;
  double? amount;
  final DateTime date;

  CoffeeRecordsModel({
    required this.id,
    required this.title,
    required this.des,
    this.amount,
    required this.date,
  });

}