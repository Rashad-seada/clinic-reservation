
// ... (previous content)
// This file will be created to define the ReservationItem model
class ReservationItem {
  final int id;
  final String type; // 'clinic' or 'home'
  final String title; // Doctor name or Service name
  final String subtitle; // Specialty or Symptoms
  final DateTime date;
  final String time;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? location;
  final String? phone;
  final String? notes;
  final String? imageUrl;

  ReservationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.status,
    this.location,
    this.phone,
    this.notes,
    this.imageUrl,
  });
}
