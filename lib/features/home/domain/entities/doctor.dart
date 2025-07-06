class Doctor {
  final int id;
  final String name;

  const Doctor({
    required this.id,
    required this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'Doctor(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
} 