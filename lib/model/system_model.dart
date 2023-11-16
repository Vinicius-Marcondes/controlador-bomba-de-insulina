class SystemModel {
  int? id;
  final int initialized;

  SystemModel({this.id, required this.initialized});

  // From map
  SystemModel.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        initialized = map["initialized"];

  // To map
  Map<String, dynamic> toMap() => {
        "id": id,
        "initialized": initialized,
      };
}
