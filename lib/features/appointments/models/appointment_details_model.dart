class AppointmentDetailsModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String bookingDate;
  final String startDate;
  final String endDate;
  final String customerPaid;
  final String paymentStatus;
  final String paymentMethod;
  final String maxPerson;
  final String orderStatus;
  final String serviceName;
  final String serviceAddress;
  final String customerAddress;
  final String customerCountry;
  final String vendorCountry;
  final String vendorAddress;
  final String serviceDescription;
  final String staffName;
  final String? vendorName;
  final String? adminName;
  final String vendorPhone;
  final String vendorEmail;

  final int serviceId;
  final String serviceSlug;

  AppointmentDetailsModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.customerPaid,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.maxPerson,
    required this.orderStatus,
    required this.serviceName,
    required this.serviceAddress,
    required this.customerAddress,
    required this.customerCountry,
    required this.vendorCountry,
    required this.vendorAddress,
    required this.serviceDescription,
    required this.staffName,
    this.vendorName,
    this.adminName,
    required this.vendorPhone,
    required this.vendorEmail,
    required this.serviceId,
    required this.serviceSlug,
  });

  /// Factory that safely parses JSON and builds a combined adminName.
  factory AppointmentDetailsModel.fromJson(Map<String, dynamic> json) {
    // Helper to trim strings and turn empty -> null
    String? nonEmpty(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final appointment = (json['appointment'] as Map<String, dynamic>?) ?? {};
    final serviceContents =
        (appointment['service_content'] as List?) ?? const [];
    final serviceContent =
    serviceContents.isNotEmpty ? (serviceContents.first as Map<String, dynamic>?) ?? {} : {};

    final staff  = (json['staff']  as Map<String, dynamic>?) ?? {};
    final vendor = (json['vendor'] as Map<String, dynamic>?) ?? {};
    final admin  = (vendor['admin'] as Map<String, dynamic>?) ?? {};

    // Compose admin full name if present
    final adminFirst = nonEmpty(admin['first_name']) ?? nonEmpty(vendor['first_name']);
    final adminLast  = nonEmpty(admin['last_name'])  ?? nonEmpty(vendor['last_name']);
    final adminFullName = (adminFirst != null || adminLast != null)
        ? [adminFirst, adminLast].where((p) => p != null && p.isNotEmpty).join(' ')
        : nonEmpty(admin['username']);

    return AppointmentDetailsModel(
      id: appointment['id'] ?? 0,
      orderNumber: nonEmpty(appointment['order_number']) ?? '',
      customerName: nonEmpty(appointment['customer_name']) ?? '',
      customerPhone: nonEmpty(appointment['customer_phone']) ?? '',
      customerEmail: nonEmpty(appointment['customer_email']) ?? '',
      bookingDate: nonEmpty(appointment['booking_date']) ?? '',
      startDate: nonEmpty(appointment['start_date']) ?? '',
      endDate: nonEmpty(appointment['end_date']) ?? '',
      customerPaid: nonEmpty(appointment['customer_paid']) ?? '',
      paymentStatus: nonEmpty(appointment['payment_status']) ?? '',
      paymentMethod: nonEmpty(appointment['payment_method']) ?? '',
      maxPerson: (appointment['max_person']?.toString() ?? '').trim(),
      orderStatus: nonEmpty(appointment['order_status']) ?? '',
      serviceName: nonEmpty(serviceContent['name']) ?? '',
      serviceAddress: nonEmpty(serviceContent['address']) ?? '',
      customerAddress: nonEmpty(appointment['customer_address']) ?? '',
      customerCountry: nonEmpty(appointment['customer_country']) ?? '',
      vendorCountry: nonEmpty(vendor['country']) ?? '',
      vendorAddress: nonEmpty(vendor['address']) ?? '',
      serviceDescription: nonEmpty(serviceContent['description']) ?? '',
      staffName: nonEmpty(staff['name']) ?? '',
      vendorName: nonEmpty(vendor['name']),
      adminName: adminFullName, // First + last (or username) if present
      vendorPhone: nonEmpty(vendor['phone']) ?? '',
      vendorEmail: nonEmpty(vendor['email']) ?? '',
      serviceId: parseInt(serviceContent['service_id']),
      serviceSlug: nonEmpty(serviceContent['slug']) ?? '',
    );
  }
}
