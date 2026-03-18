import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import 'auth_service.dart';

/// Bridges Firestore real-time device list → local Device model list.
/// This replaces the old demo-data devices provider when signed in.
final accountDevicesProvider = StreamProvider<List<Device>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final registry = ref.read(deviceRegistryProvider);
  return registry.devicesStream(user.uid).map((list) =>
    list.map((d) => Device(
      id:       d['deviceId'] as String? ?? '',
      name:     d['name']     as String? ?? 'Unknown',
      type:     _parseType(d['platform'] as String? ?? ''),
      ip:       d['ip']       as String? ?? '',
      port:     (d['port']    as int?)   ?? 5050,
      status:   (d['online'] as bool? ?? false)
                    ? DeviceStatus.online
                    : DeviceStatus.offline,
      capabilities: Map<String, bool>.from(
          (d['capabilities'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as bool? ?? false))),
    )).toList(),
  );
});

DeviceType _parseType(String p) => switch (p.toLowerCase()) {
  'windows' => DeviceType.windows,
  'linux'   => DeviceType.linux,
  'android' => DeviceType.android,
  'ios'     => DeviceType.ios,
  'macos'   => DeviceType.macos,
  _         => DeviceType.unknown,
};
