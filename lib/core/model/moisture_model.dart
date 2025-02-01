class MoistureModel {
  final int value;
  final DateTime timeStamp;

  MoistureModel({required this.value, required this.timeStamp});

  factory MoistureModel.fromJson(Map<String, dynamic> json) {
    return MoistureModel(
      value: json['value'],
      timeStamp: DateTime.parse(json['timeStamp']),
    );
  }
}
