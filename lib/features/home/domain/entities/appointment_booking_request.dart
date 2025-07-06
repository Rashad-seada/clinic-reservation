class AppointmentBookingRequest {
  final int clinicId;
  final int doctorId;
  final int serviceId;
  final int patientId;
  final String availableDate;
  final String availableTime;
  final String symptoms;
  final String model;

  AppointmentBookingRequest({
    required this.clinicId,
    required this.doctorId,
    required this.serviceId,
    required this.patientId,
    required this.availableDate,
    required this.availableTime,
    required this.symptoms,
    this.model = "clinic",
  });

  Map<String, dynamic> toJson() {
    final timeComponents = availableTime.split(':');
    final formattedTime = timeComponents.length == 2 
        ? "${timeComponents[0]}:${timeComponents[1]}:00"
        : availableTime;

    return {
      'ClinicId': clinicId,
      'DoctorId': doctorId,
      'ServiceId': serviceId,
      'PatientId': patientId,
      'availableDate': availableDate,
      'availableTime': formattedTime,
      'Symptoms': symptoms,
      'model': model,
    };
  }
} 