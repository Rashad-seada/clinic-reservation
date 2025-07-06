class BookingAppointmentData {
  final List<Clinic> clinics;
  final List<InsuranceCompany> insuranceCompanies;
  final List<DiscountCard> discountCards;
  final List<WorkplaceCard> workplaceCards;
  final List<City> cities;

  BookingAppointmentData({
    required this.clinics,
    required this.insuranceCompanies,
    required this.discountCards,
    required this.workplaceCards,
    required this.cities,
  });

  factory BookingAppointmentData.fromJson(Map<String, dynamic> json) {
    return BookingAppointmentData(
      clinics: (json['clinics'] as List<dynamic>)
          .map((e) => Clinic.fromJson(e as Map<String, dynamic>))
          .toList(),
      insuranceCompanies: (json['insuranceCompanies'] as List<dynamic>)
          .map((e) => InsuranceCompany.fromJson(e as Map<String, dynamic>))
          .toList(),
      discountCards: (json['discountCards'] as List<dynamic>)
          .map((e) => DiscountCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      workplaceCards: (json['workplaceCards'] as List<dynamic>)
          .map((e) => WorkplaceCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      cities: (json['cities'] as List<dynamic>)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinics': clinics.map((e) => e.toJson()).toList(),
      'insuranceCompanies': insuranceCompanies.map((e) => e.toJson()).toList(),
      'discountCards': discountCards.map((e) => e.toJson()).toList(),
      'workplaceCards': workplaceCards.map((e) => e.toJson()).toList(),
      'cities': cities.map((e) => e.toJson()).toList(),
    };
  }
}

class Clinic {
  final int id;
  final String name;

  Clinic({required this.id, required this.name});

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class InsuranceCompany {
  final int id;
  final String name;

  InsuranceCompany({required this.id, required this.name});

  factory InsuranceCompany.fromJson(Map<String, dynamic> json) {
    return InsuranceCompany(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DiscountCard {
  final int id;
  final String name;

  DiscountCard({required this.id, required this.name});

  factory DiscountCard.fromJson(Map<String, dynamic> json) {
    return DiscountCard(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class WorkplaceCard {
  final int id;
  final String name;

  WorkplaceCard({required this.id, required this.name});

  factory WorkplaceCard.fromJson(Map<String, dynamic> json) {
    return WorkplaceCard(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
} 