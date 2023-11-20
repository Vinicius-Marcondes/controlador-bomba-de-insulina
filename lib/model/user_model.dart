class UserModel {
  final String firstName;
  final String lastName;
  String? image;
  final String? birthDate;
  double? height;
  double? weight;
  String? diabetesType;
  double? basalInsulin;
  double? insulinRate;

  UserModel({
      required this.firstName,
      required this.lastName,
      required this.birthDate,
      this.image
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthdate': birthDate,
      'image': image,
      'birthDate': birthDate,
      'height': height,
      'weight': weight,
      'diabetesType': diabetesType,
      'basalInsulin': basalInsulin,
      'insulinRate': insulinRate,
    };
  }

  UserModel.fromMap(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        birthDate = map['birthDate'],
        image = map['image'],
        height = map['height'],
        weight = map['weight'],
        diabetesType = map['diabetesType'],
        basalInsulin = map['basalInsulin'],
        insulinRate = map['insulinRate'] != null ? double.parse(map['insulinRate']): null;
}
