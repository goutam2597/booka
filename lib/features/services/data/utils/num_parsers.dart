// lib/features/services/data/utils/num_parsers.dart

double parsePrice(String? raw) {
  if (raw == null) return 0.0;
  // Remove currency symbols, commas, spaces
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
  if (cleaned.isEmpty) return 0.0;
  return double.tryParse(cleaned) ?? 0.0;
}

double parseRating(String? raw) {
  if (raw == null) return 0.0;
  final cleaned = raw.trim();
  if (cleaned.isEmpty) return 0.0;
  return double.tryParse(cleaned) ?? 0.0;
}
