
class NotificationModel {
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final AppointmentNotificationData? data;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data?.toMap(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] ?? 'No Title',
      body: map['body'] ?? 'No Body',
      type: map['type'] ?? 'general',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      data: map['data'] != null
          ? AppointmentNotificationData.fromMap(
        Map<String, dynamic>.from(map['data']),
      )
          : null,
      isRead: map['isRead'] ?? false,
    );
  }
}

class AppointmentNotificationData {
  final String serviceTitle;
  final String serviceSlug;
  final int? serviceId; // <-- now stored as int
  final int? userId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final String customerCountry;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int? vendorId;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String orderNumber;
  final String zoomInfo;
  final String customerPaid;

  AppointmentNotificationData({
    required this.serviceTitle,
    required this.serviceSlug,
    this.serviceId,
    this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    required this.customerCountry,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.vendorId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.orderNumber,
    required this.zoomInfo,
    required this.customerPaid,
  });

  factory AppointmentNotificationData.fromMap(Map<String, dynamic> map) {
    return AppointmentNotificationData(
      serviceTitle: map['service_title'] ?? '',
      serviceSlug: map['service_slug'] ?? '',
      serviceId: int.tryParse(map['service_id']?.toString() ?? ''),
      userId: int.tryParse(map['user_id']?.toString() ?? ''),
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      customerEmail: map['customer_email'] ?? '',
      customerAddress: map['customer_address'] ?? '',
      customerCountry: map['customer_country'] ?? '',
      bookingDate: map['booking_date'] ?? '',
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
      vendorId: int.tryParse(map['vendor_id']?.toString() ?? ''),
      paymentMethod: map['payment_method'] ?? '',
      paymentStatus: map['payment_status'] ?? '',
      orderStatus: map['order_status'] ?? '',
      orderNumber: map['order_number'] ?? '',
      zoomInfo: map['zoom_info'] ?? '',
      customerPaid: map['customer_paid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_title': serviceTitle,
      'service_slug': serviceSlug,
      'service_id': serviceId,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'customer_country': customerCountry,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'vendor_id': vendorId,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'order_number': orderNumber,
      'zoom_info': zoomInfo,
      'customer_paid': customerPaid,
    };
  }
}
