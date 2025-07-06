class Patient {
  final int? id;
  final String? username;
  final String? birthDate;
  final String? idNumber;
  final String? idType;
  final String? email;
  final String? phone;
  final String? nationality;
  final String? religon;
  final String? educationLevel;

  Patient({
    this.id,
    this.username,
    this.birthDate,
    this.idNumber,
    this.idType,
    this.email,
    this.phone,
    this.nationality,
    this.religon,
    this.educationLevel,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      username: json['username'],
      birthDate: json['birthDate'],
      idNumber: json['idNumber'],
      idType: json['idType'],
      email: json['email'],
      phone: json['phone'],
      nationality: json['nationality'],
      religon: json['religon'],
      educationLevel: json['educationLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'birthDate': birthDate,
      'idNumber': idNumber,
      'idType': idType,
      'email': email,
      'phone': phone,
      'nationality': nationality,
      'religon': religon,
      'educationLevel': educationLevel,
    };
  }
} 