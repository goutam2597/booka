class AvailableTimeResponseModel {
  final int id;
  final String startTime;
  final String endTime;
  final int? maxPerson;

  const AvailableTimeResponseModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.maxPerson,
  });

  factory AvailableTimeResponseModel.fromJson(
    Map<String, dynamic> json, {
    int? maxPerson,
  }) {
    return AvailableTimeResponseModel(
      id: (json['id'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      maxPerson: maxPerson,
    );
  }

  static List<AvailableTimeResponseModel> fromGlobalTimeList(
    List<dynamic> list, {
    int? maxPerson,
  }) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => AvailableTimeResponseModel.fromJson(e, maxPerson: maxPerson),
        )
        .toList();
  }
}
