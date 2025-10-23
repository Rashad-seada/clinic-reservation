class HomeVisitRequest {
  final int clinicId;
  final int patientId;
  final int cityId;
  final String mobile;
  final String address;
  final String location;
  final String visitDate;
  final String time;
  final String service;
  final String symptoms;
  final int serviceId;
  HomeVisitRequest({
    required this.clinicId,
    required this.patientId,
    required this.cityId,
    required this.mobile,
    required this.address,
    required this.location,
    required this.visitDate,
    required this.time,
    required this.service,
    required this.symptoms,
    required this.serviceId
  });

  Map<String, dynamic> toJson() {
    return {
      'clinicId': clinicId,
      'patientId': patientId,
      'cityId': cityId,
      'mobile': mobile,
      'address': address,
      'location': location,
      'visitDate': visitDate,
      'time': time,
      'service': service,
      'symptoms': symptoms,
      'serviceId' : serviceId
    };
  }
} 