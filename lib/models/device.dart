import 'package:flutter/material.dart';

enum DeviceType { windows, linux, android, ios, macos, web, unknown }
enum DeviceStatus { online, offline, connecting }

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final String ip;
  final int port;
  DeviceStatus status;
  final Map<String, bool> capabilities; // transfer, stream, mouse, clipboard

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.ip,
    this.port = 5050,
    this.status = DeviceStatus.offline,
    Map<String, bool>? capabilities,
  }) : capabilities = capabilities ??
            {
              'transfer': true,
              'stream': false,
              'mouse': false,
              'clipboard': true,
            };

  IconData get icon => switch (type) {
        DeviceType.windows => Icons.laptop_windows_rounded,
        DeviceType.linux => Icons.computer_rounded,
        DeviceType.android => Icons.phone_android_rounded,
        DeviceType.ios => Icons.phone_iphone_rounded,
        DeviceType.macos => Icons.laptop_mac_rounded,
        _ => Icons.devices_rounded,
      };

  Color get color => switch (type) {
        DeviceType.windows => const Color(0xFF0078D4),
        DeviceType.linux => const Color(0xFFE95420),
        DeviceType.android => const Color(0xFF3DDC84),
        DeviceType.ios => const Color(0xFF888888),
        DeviceType.macos => const Color(0xFF888888),
        _ => const Color(0xFF6C63FF),
      };

  String get typeLabel => switch (type) {
        DeviceType.windows => 'Windows',
        DeviceType.linux => 'Linux',
        DeviceType.android => 'Android',
        DeviceType.ios => 'iOS',
        DeviceType.macos => 'macOS',
        _ => 'Unknown',
      };

  Device copyWith({DeviceStatus? status}) =>
      Device(
        id: id,
        name: name,
        type: type,
        ip: ip,
        port: port,
        status: status ?? this.status,
        capabilities: capabilities,
      );
}

// Demo devices - in real app these come from mDNS discovery
final demoDevices = [
  Device(
    id: 'win-1',
    name: 'Windows Laptop',
    type: DeviceType.windows,
    ip: '192.168.1.101',
    status: DeviceStatus.online,
    capabilities: {'transfer': true, 'stream': true, 'mouse': true, 'clipboard': true},
  ),
  Device(
    id: 'linux-1',
    name: 'Linux Laptop',
    type: DeviceType.linux,
    ip: '192.168.1.102',
    status: DeviceStatus.online,
    capabilities: {'transfer': true, 'stream': true, 'mouse': true, 'clipboard': true},
  ),
  Device(
    id: 'android-1',
    name: 'Pixel 8 Pro',
    type: DeviceType.android,
    ip: '192.168.1.103',
    status: DeviceStatus.online,
    capabilities: {'transfer': true, 'stream': false, 'mouse': false, 'clipboard': true},
  ),
  Device(
    id: 'android-2',
    name: 'Samsung Tab S9',
    type: DeviceType.android,
    ip: '192.168.1.104',
    status: DeviceStatus.offline,
    capabilities: {'transfer': true, 'stream': false, 'mouse': false, 'clipboard': true},
  ),
];
