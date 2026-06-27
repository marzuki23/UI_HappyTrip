class TripLog {
  final String title;
  final String dateRange;
  final String destination;
  final String vehicleType;
  final int durationDays;
  final double totalCost;
  final double budget;
  final bool isWithinBudget;
  final List<Map<String, dynamic>> destinations;
  final DateTime savedAt;

  TripLog({
    required this.title,
    required this.dateRange,
    required this.destination,
    required this.vehicleType,
    required this.durationDays,
    required this.totalCost,
    required this.budget,
    required this.isWithinBudget,
    required this.destinations,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateRange': dateRange,
      'destination': destination,
      'vehicleType': vehicleType,
      'durationDays': durationDays,
      'totalCost': totalCost,
      'budget': budget,
      'isWithinBudget': isWithinBudget,
      'destinations': destinations,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory TripLog.fromJson(Map<String, dynamic> json) {
    return TripLog(
      title: json['title'] ?? '',
      dateRange: json['dateRange'] ?? '',
      destination: json['destination'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      durationDays: json['durationDays'] ?? 1,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      isWithinBudget: json['isWithinBudget'] ?? true,
      destinations: List<Map<String, dynamic>>.from(json['destinations'] ?? []),
      savedAt: json['savedAt'] != null ? DateTime.parse(json['savedAt']) : DateTime.now(),
    );
  }
}
