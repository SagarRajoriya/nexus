import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import 'devices_provider.dart';
import 'dart:typed_data';

/// Nexus devices announce themselves on UDP port 5353 (mDNS-like)
/// and also respond to a JSON HTTP ping on port 5050.
/// This service does two things:
///   1. Broadcasts a UDP presence packet on the LAN so others can find us
///   2. Scans the /24 subnet pinging each host's port 5050
class DiscoveryService {
  static const int _nexusPort = 5050;
  static const Duration _timeout = Duration(seconds: 1);

  final DevicesNotifier _notifier;
  Timer? _broadcastTimer;
  RawDatagramSocket? _udpSocket;

  DiscoveryService(this._notifier);

  /// Start periodic LAN scan + UDP broadcast
  Future<void> start() async {
    await _startUdpListener();
    await scanNow();
    _broadcastTimer = Timer.periodic(const Duration(seconds: 30), (_) => scanNow());
  }

  void stop() {
    _broadcastTimer?.cancel();
    _udpSocket?.close();
  }

  /// Scan entire /24 subnet concurrently
  Future<void> scanNow() async {
    final myIp = await _getLocalIp();
    if (myIp == null) return;

    final prefix = myIp.substring(0, myIp.lastIndexOf('.'));
    final futures = List.generate(254, (i) => _probeHost('$prefix.${i + 1}'));
    await Future.wait(futures, eagerError: false);
  }

  Future<void> _probeHost(String ip) async {
    try {
      final socket = await Socket.connect(ip, _nexusPort,
          timeout: const Duration(milliseconds: 800));
      socket.write(jsonEncode({'type': 'ping', 'from': await _getLocalIp()}));
      await socket.flush();

      final response = await socket.first
          .timeout(const Duration(milliseconds: 500), onTimeout: () => Uint8List(0));
      socket.destroy();

      if (response.isEmpty) return;
      final data = jsonDecode(utf8.decode(response)) as Map<String, dynamic>;
      _handleDiscovered(ip, data);
    } catch (_) {
      // Host not running Nexus daemon — ignore silently
    }

  }

  void _handleDiscovered(String ip, Map<String, dynamic> data) {
    final device = Device(
      id: data['id'] as String? ?? ip,
      name: data['name'] as String? ?? 'Unknown device',
      type: _parseType(data['os'] as String? ?? ''),
      ip: ip,
      port: _nexusPort,
      status: DeviceStatus.online,
      capabilities: {
        'transfer':  true,
        'stream':    data['sunshine'] == true,
        'mouse':     data['barrier'] == true,
        'clipboard': true,
      },
    );
    _notifier.addOrUpdate(device);
  }

  DeviceType _parseType(String os) {
    final lower = os.toLowerCase();
    if (lower.contains('windows')) return DeviceType.windows;
    if (lower.contains('linux'))   return DeviceType.linux;
    if (lower.contains('android')) return DeviceType.android;
    if (lower.contains('ios'))     return DeviceType.ios;
    if (lower.contains('macos'))   return DeviceType.macos;
    return DeviceType.unknown;
  }

  Future<void> _startUdpListener() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4, _nexusPort + 1);
      _udpSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = _udpSocket!.receive();
          if (dg == null) return;
          try {
            final data = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
            if (data['type'] == 'nexus_hello') {
              _handleDiscovered(dg.address.address, data);
            }
          } catch (_) {}
        }
      });
    } catch (_) {}
  }

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLinkLocal: false);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return null;
  }
}

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final notifier = ref.read(devicesProvider.notifier);
  final service = DiscoveryService(notifier);
  ref.onDispose(service.stop);
  return service;
});

