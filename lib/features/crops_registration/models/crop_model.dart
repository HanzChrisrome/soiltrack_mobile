class Crop {
  final String cropName;
  final int minMoisture;
  final int maxMoisture;
  final int minNitrogen;
  final int maxNitrogen;
  final int minPotassium;
  final int maxPotassium;
  final int minPhosphorus;
  final int maxPhosphorus;

  Crop({
    required this.cropName,
    required this.minMoisture,
    required this.maxMoisture,
    required this.minNitrogen,
    required this.maxNitrogen,
    required this.minPotassium,
    required this.maxPotassium,
    required this.minPhosphorus,
    required this.maxPhosphorus,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      cropName: json['crop_name'] as String,
      minMoisture: json['moisture_min'] as int,
      maxMoisture: json['moisture_max'] as int,
      minNitrogen: json['nitrogen_min'] as int,
      maxNitrogen: json['nitrogen_max'] as int,
      minPotassium: json['potassium_min'] as int,
      maxPotassium: json['potassium_max'] as int,
      minPhosphorus: json['phosphorus_min'] as int,
      maxPhosphorus: json['phosphorus_max'] as int,
    );
  }
}
