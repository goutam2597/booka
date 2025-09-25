class DateTimeResponseModel {
  final List<String> globalWeekend;
  final List<dynamic> globalHoliday;
  final String vendorId;
  final String serviceId;

  DateTimeResponseModel({
    required this.globalWeekend,
    required this.globalHoliday,
    required this.vendorId,
    required this.serviceId,
  });

  factory DateTimeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DateTimeResponseModel(
      globalWeekend: (data['globalWeekend'] as List).cast<String>(),
      globalHoliday: data['globalHoliday'] as List<dynamic>,
      vendorId: data['vendor_id'] as String,
      serviceId: data['serviceId'] as String,
    );
  }
}