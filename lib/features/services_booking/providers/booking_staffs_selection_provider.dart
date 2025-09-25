import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/network_service/core/booking_network_service.dart';
import 'package:bookapp_customer/app/assets_path.dart';

/// Handles loading & normalizing staff list for a service.
class BookingStaffsSelectionProvider extends ChangeNotifier {
  BookingStaffsSelectionProvider({required this.service});

  final ServicesModel service;

  bool _loading = true;
  bool get loading => _loading;

  List<StaffModel> _staffs = [];
  List<StaffModel> get staffs => _staffs;

  /// Load only once.
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _staffs = await _loadStaffs();
    } catch (_) {
      _staffs = [_createAdminAsStaff()];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<StaffModel>> _loadStaffs() async {
    if (service.vendorId == 0) {
      return [_createAdminAsStaff()];
    }
    try {
      final apiList = await BookingNetworkService.getStaffByService(service.id);
      final normalized = _dedupeStaffs(apiList);
      if (normalized.isEmpty) return [_createAdminAsStaff()];
      return normalized;
    } catch (_) {
      return [_createAdminAsStaff()];
    }
  }

  StaffModel _createAdminAsStaff() {
    final admin = service.admin;
    final vendor = service.vendor;

    String firstNonEmpty(List<String?> vals, {String orElse = ''}) {
      for (final v in vals) {
        if (v != null && v.trim().isNotEmpty) return v.trim();
      }
      return orElse;
    }

    String fullName({String? first, String? last, String? username}) {
      final f = (first ?? '').trim();
      final l = (last ?? '').trim();
      if (f.isNotEmpty || l.isNotEmpty) {
        return [f, l].where((s) => s.isNotEmpty).join(' ');
      }
      return (username ?? '').trim();
    }

    final adminDisplayName = firstNonEmpty([
      fullName(
        first: admin?.firstName,
        last: admin?.lastName,
        username: admin?.username,
      ),
      fullName(username: vendor?.username),
      admin?.username,
      vendor?.username,
    ], orElse: 'Admin');

    final image = firstNonEmpty([vendor?.photo, admin?.image]);
    final email = firstNonEmpty([vendor?.email, admin?.email]);

    return StaffModel(
      id: 1,
      name: adminDisplayName,
      email: email.isEmpty ? 'admin@bookapp.com' : email,
      image: image.isEmpty ? AssetsPath.defaultVendor : image,
      vendorId: service.vendorId,
      adminId: admin?.id ?? 0,
      isFallback: true,
      kind: 'admin_fallback',
    );
  }

  StaffModel _safeStaff(StaffModel s) {
    String clean(String? v) => (v ?? '').trim();
    return StaffModel(
      id: s.id,
      name: clean(s.name).isEmpty ? 'Staff' : clean(s.name),
      email: clean(s.email),
      image: clean(s.image).isEmpty ? AssetsPath.defaultVendor : clean(s.image),
      vendorId: s.vendorId,
      adminId: s.adminId,
      isFallback: s.isFallback,
      kind: s.kind,
    );
  }

  List<StaffModel> _dedupeStaffs(List<StaffModel> input) {
    final seenById = <int>{};
    final seenByKey = <String>{};
    final out = <StaffModel>[];
    for (final s in input) {
      final cleaned = _safeStaff(s);
      final id = cleaned.id;
      if (id > 0) {
        if (seenById.contains(id)) continue;
        seenById.add(id);
        out.add(cleaned);
        seenByKey.add(_softKey(cleaned));
        continue;
      }
      final key = _softKey(cleaned);
      if (seenByKey.contains(key)) continue;
      seenByKey.add(key);
      out.add(cleaned);
    }
    final fallbackKey = _softKey(_createAdminAsStaff());
    final filtered = out.whereIndexed((i, s) {
      if (_softKey(s) != fallbackKey) return true;
      return out.indexWhere((x) => _softKey(x) == fallbackKey) == i;
    }).toList();
    return filtered;
  }

  String _softKey(StaffModel s) {
    final email = (s.email).trim().toLowerCase();
    final name = (s.name).trim().toLowerCase();
    return email.isNotEmpty ? 'e:$email' : 'n:$name';
  }
}

extension _IterableWhereIndexed<E> on Iterable<E> {
  Iterable<E> whereIndexed(bool Function(int index, E e) test) sync* {
    var i = 0;
    for (final e in this) {
      if (test(i, e)) yield e;
      i++;
    }
  }
}
