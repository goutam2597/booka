class AppointmentModel {
  final int id;
  final String name;
  final String slug;
  final String bookingDate;
  final String startDate;
  final String endDate;
  final String vendorId;
  final String orderStatus;
  final String serviceId;

  AppointmentModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.vendorId,
    required this.orderStatus,
    required this.serviceId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        bookingDate: json['booking_date'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        vendorId: json['vendor_id'].toString(),
        orderStatus: json['order_status'],
        serviceId: json['service_id'].toString(),
      );
}
