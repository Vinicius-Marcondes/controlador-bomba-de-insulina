class InsulinEntryModel {
  int? id;
  int units;
  DateTime timestamp;
  int? glicemia;
  final int userId = 0;

  InsulinEntryModel({
    this.id,
    required this.units,
    required this.timestamp, this.glicemia,
  });

  factory InsulinEntryModel.fromMap(Map<String, dynamic> map) => InsulinEntryModel(
    id: map['id'],
    units: map['units'],
    timestamp: DateTime.parse(map['timestamp']),
    glicemia: map['glicemia'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'units': units,
    'glicemia': glicemia,
    'timestamp': timestamp.toString(),
    'userId': userId,
  };
}