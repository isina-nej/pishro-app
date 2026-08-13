import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';

@immutable
class AccountProfile {
  const AccountProfile({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.phoneVerified = false,
    this.role,
  });

  final String id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final bool phoneVerified;
  final String? role;

  String get displayName {
    final full = [firstName, lastName].whereType<String>().join(' ').trim();
    return full.isEmpty ? Fmt.maskPhone(phone) : full;
  }

  factory AccountProfile.fromJson(Map<String, dynamic> json) => AccountProfile(
    id: '${json['id'] ?? ''}',
    phone: '${json['phone'] ?? ''}',
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    email: json['email'] as String?,
    avatarUrl: json['image'] as String? ?? json['avatar'] as String?,
    phoneVerified: json['phoneVerified'] == true,
    role: json['role'] as String?,
  );
}

enum KycStatus { missing, pending, verified }

extension KycStatusLabel on KycStatus {
  String get label => switch (this) {
    KycStatus.missing => 'تکمیل نشده',
    KycStatus.pending => 'در حال بررسی',
    KycStatus.verified => 'تأییدشده',
  };
}

@immutable
class KycSnapshot {
  const KycSnapshot({
    required this.identity,
    required this.iban,
    required this.address,
    required this.selfie,
  });

  final KycStatus identity;
  final KycStatus iban;
  final KycStatus address;
  final KycStatus selfie;

  List<KycStatus> get _all => [identity, iban, address, selfie];

  bool get isComplete => _all.every((s) => s == KycStatus.verified);

  /// Weighted 0–1 for the Account/Home progress bar. Pending counts as half.
  double get completion {
    double score(KycStatus s) => switch (s) {
      KycStatus.verified => 1,
      KycStatus.pending => 0.5,
      KycStatus.missing => 0,
    };
    return _all.fold<double>(0, (sum, s) => sum + score(s)) / _all.length;
  }
}

@immutable
class CoinLedgerEntry {
  const CoinLedgerEntry({
    required this.id,
    required this.title,
    required this.delta,
    required this.at,
  });

  final String id;
  final String title;
  final int delta;
  final DateTime at;
}

@immutable
class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.name,
    required this.lastSeen,
    this.current = false,
    this.ip,
  });

  final String id;
  final String name;
  final DateTime lastSeen;
  final bool current;

  /// Raw IP if known; UI must mask it.
  final String? ip;

  /// «۱۹۲٫۱۶۸٫•․•»
  String get maskedIp {
    if (ip == null || ip!.isEmpty) return '';
    final parts = ip!.split('.');
    if (parts.length < 2) return Fmt.fa(ip!);
    return Fmt.fa('${parts[0]}.${parts[1]}.•.•');
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime at;
  final bool read;
}

@immutable
class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.invites,
    required this.note,
  });

  final String code;
  final int invites;
  final String note;
}

abstract class AccountRepository {
  Future<AccountProfile> me();

  Future<AccountProfile> updatePersonal({
    required String firstName,
    required String lastName,
    String? email,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

abstract class AccountMockRepository {
  Future<KycSnapshot> kyc();

  Future<List<CoinLedgerEntry>> coinLedger();

  Future<List<DeviceSession>> devices();

  Future<List<AppNotification>> notifications();

  Future<ReferralInfo> referrals();
}

class ApiAccountRepository implements AccountRepository {
  const ApiAccountRepository(this._api);

  final ApiClient _api;

  @override
  Future<AccountProfile> me() async {
    final data = await _api.get<Map<String, dynamic>>('/user/me');
    return AccountProfile.fromJson(data);
  }

  @override
  Future<AccountProfile> updatePersonal({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/user/personal',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
    );
    return AccountProfile.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post<Map<String, dynamic>>(
      '/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}

class MockAccountExtras implements AccountMockRepository {
  @override
  Future<KycSnapshot> kyc() async => const KycSnapshot(
    identity: KycStatus.verified,
    iban: KycStatus.pending,
    address: KycStatus.missing,
    selfie: KycStatus.pending,
  );

  @override
  Future<List<CoinLedgerEntry>> coinLedger() async {
    final now = DateTime.now();
    return [
      CoinLedgerEntry(
        id: 'c1',
        title: 'تکمیل دوره',
        delta: 100,
        at: now.subtract(const Duration(days: 2)),
      ),
      CoinLedgerEntry(
        id: 'c2',
        title: 'دعوت دوست',
        delta: 100,
        at: now.subtract(const Duration(days: 8)),
      ),
      CoinLedgerEntry(
        id: 'c3',
        title: 'تخفیف خرید',
        delta: -50,
        at: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  @override
  Future<List<DeviceSession>> devices() async {
    final now = DateTime.now();
    return [
      DeviceSession(
        id: 'd1',
        name: 'این دستگاه · Android',
        lastSeen: now,
        current: true,
        ip: '192.168.1.24',
      ),
      DeviceSession(
        id: 'd2',
        name: 'Chrome · Windows',
        lastSeen: now.subtract(const Duration(days: 3)),
        ip: '10.0.0.18',
      ),
    ];
  }

  @override
  Future<List<AppNotification>> notifications() async {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'پرداخت دوره',
        body: 'سفارش شما در حال بررسی است.',
        at: now.subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: 'n2',
        title: 'خبر جدید',
        body: 'یک خبر ذخیره‌شده به‌روزرسانی شد.',
        at: now.subtract(const Duration(days: 1)),
        read: true,
      ),
    ];
  }

  @override
  Future<ReferralInfo> referrals() async => const ReferralInfo(
    code: 'PSHRO-۸۴۲۱',
    invites: 3,
    note: 'سکه دعوت غیرقابل برداشت است و نرخ تبدیل ثابتی ندارد.',
  );
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => ApiAccountRepository(ref.watch(apiClientProvider)),
);

final accountMockProvider = Provider<AccountMockRepository>(
  (ref) => MockAccountExtras(),
);

final accountProfileProvider = FutureProvider<AccountProfile>(
  (ref) => ref.watch(accountRepositoryProvider).me(),
);

final kycSnapshotProvider = FutureProvider<KycSnapshot>((ref) {
  if (!AppConfig.useMockForMissingApis) {
    return ref.watch(accountMockProvider).kyc();
  }
  return ref.watch(accountMockProvider).kyc();
});

final coinLedgerProvider = FutureProvider<List<CoinLedgerEntry>>(
  (ref) => ref.watch(accountMockProvider).coinLedger(),
);

final devicesProvider = FutureProvider<List<DeviceSession>>(
  (ref) => ref.watch(accountMockProvider).devices(),
);

final notificationsProvider = FutureProvider<List<AppNotification>>(
  (ref) => ref.watch(accountMockProvider).notifications(),
);

final referralsProvider = FutureProvider<ReferralInfo>(
  (ref) => ref.watch(accountMockProvider).referrals(),
);
