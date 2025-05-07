class TaskModel {
  final int id;
  final String name;
  final String message;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final int? jobId;  // Nullable jobId

  TaskModel({
    required this.id,
    required this.name,
    required this.message,
    required this.startTime,
    required this.endTime,
    required this.allDay,
    this.jobId,  // Nullable
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Brak nazwy',
      message: json['message'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      allDay: json['allDay'].toString().toLowerCase() == 'true',
      jobId: json['jobId'],  // Keep null if not provided
    );
  }
}
