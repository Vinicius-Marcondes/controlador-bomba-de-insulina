class SystemModel {
  int? id;
  int initialized;
  String? pumpRemoteId;
  int pumpLocked = 0;
  int insulinStock = 0;

  SystemModel({this.id, required this.initialized});
  SystemModel.withPump({this.id, required this.initialized, required String pumpRemoteId});

  // From map
  SystemModel.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        initialized = map["initialized"],
        pumpRemoteId = map["pumpRemoteId"],
        pumpLocked = map["pumpLocked"],
        insulinStock = map["insulinStock"];

  // To map
  Map<String, dynamic> toMap() => {
        "id": id,
        "initialized": initialized,
        "pumpRemoteId": pumpRemoteId,
        "pumpLocked": pumpLocked,
        "insulinStock": insulinStock,
      };
}
