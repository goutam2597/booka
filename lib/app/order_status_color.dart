import 'package:flutter/material.dart';

Color getOrderStatusColor(String status) {
  switch (status) {
    case 'accepted':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'rejected':
      return Colors.redAccent;
    case 'Accepted':
      return Colors.green;
    case 'Pending':
      return Colors.orange;
    case 'Completed':
      return Colors.green;
    case 'Cancelled':
      return Colors.red;
    case 'Rejected':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}
