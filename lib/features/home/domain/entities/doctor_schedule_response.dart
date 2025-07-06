class DoctorScheduleResponse {
  final String status;
  final List<DoctorSchedule> scheduleDoctor;

  DoctorScheduleResponse({
    required this.status,
    required this.scheduleDoctor,
  });

  factory DoctorScheduleResponse.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleResponse(
      status: json['status'],
      scheduleDoctor: (json['scheduleDoctor'] as List)
          .map((schedule) => DoctorSchedule.fromJson(schedule))
          .toList(),
    );
  }
}

class DoctorSchedule {
  final DateTime date;
  final List<TimeSlot> timeSlots;

  DoctorSchedule({
    required this.date,
    required this.timeSlots,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      date: DateTime.parse(json['date']),
      timeSlots: (json['timeSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }
}

class TimeSlot {
  final bool disabled;
  final String? group;
  final bool selected;
  final String text;
  final String value;

  TimeSlot({
    required this.disabled,
    this.group,
    required this.selected,
    required this.text,
    required this.value,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      disabled: json['disabled'],
      group: json['group'],
      selected: json['selected'],
      text: json['text'],
      value: json['value'],
    );
  }
} 