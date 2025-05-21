/// Model class for a health metric entry
class MetricEntry {
  /// Unique identifier for the entry
  final String id;

  /// Primary value of the entry
  final double value;

  /// Secondary value (e.g., for blood pressure diastolic)
  final double? secondaryValue;

  /// Date of the entry
  final DateTime date;

  /// Optional note for the entry
  final String note;

  /// Constructor
  const MetricEntry({
    required this.id,
    required this.value,
    this.secondaryValue,
    required this.date,
    required this.note,
  });

  /// Create a copy of this entry with optional field updates
  MetricEntry copyWith({
    String? id,
    double? value,
    double? secondaryValue,
    DateTime? date,
    String? note,
  }) {
    return MetricEntry(
      id: id ?? this.id,
      value: value ?? this.value,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Convert the entry to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'secondaryValue': secondaryValue,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  /// Create an entry from a JSON map
  factory MetricEntry.fromJson(Map<String, dynamic> json) {
    return MetricEntry(
      id: json['id'],
      value: json['value'].toDouble(),
      secondaryValue: json['secondaryValue'] != null 
          ? json['secondaryValue'].toDouble() 
          : null,
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}