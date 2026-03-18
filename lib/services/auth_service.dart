import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign up ──────────────────────────────────────────────────
  Future<void> signUp(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(displayName);
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _registerThisDevice(cred.user!.uid);
  }

  // ── Sign in ──────────────────────────────────────────────────
  Future<void> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    await _registerThisDevice(cred.user!.uid);
  }

  // ── Sign out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final deviceId = await _getDeviceId();
      await _db
          .collection('users').doc(uid)
          .collection('devices').doc(deviceId)
          .update({'online': false});
    }
    await _auth.signOut();
  }

  // ── Register / heartbeat this device ─────────────────────────
  Future<void> _registerThisDevice(String uid) async {
    final deviceId = await _getDeviceId();
    final ip       = await _getLocalIp();
    final name     = await _getDeviceName();
    final os       = _getOs();

    await _db
        .collection('users').doc(uid)
        .collection('devices').doc(deviceId)
        .set({
      'id':        deviceId,
      'name':      name,
      'os':        os,
      'ip':        ip,
      'online':    true,
      'lastSeen':  FieldValue.serverTimestamp(),
      'sunshine':  false,
      'barrier':   false,
    }, SetOptions(merge: true));
  }

  // ── Watch all devices in the account ─────────────────────────
  Stream<List<Device>> watchDevices(String uid) {
    return _db
        .collection('users').doc(uid)
        .collection('devices')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _docToDevice(d))
            .toList());
  }

  // ── Update device capabilities (call after Sunshine is running) ─
  Future<void> updateCapabilities(String uid, {bool? sunshine, bool? barrier}) async {
    final deviceId = await _getDeviceId();
    await _db
        .collection('users').doc(uid)
        .collection('devices').doc(deviceId)
        .update({
      if (sunshine != null) 'sunshine': sunshine,
      if (barrier  != null) 'barrier': barrier,
    });
  }

  // ── Helpers ──────────────────────────────────────────────────
  Device _docToDevice(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Device(
      id:     d['id']   as String? ?? doc.id,
      name:   d['name'] as String? ?? 'Unknown',
      type:   _parseOs(d['os'] as String? ?? ''),
      ip:     d['ip']   as String? ?? '',
      status: d['online'] == true ? DeviceStatus.online : DeviceStatus.offline,
      capabilities: {
        'transfer':  true,
        'stream':    d['sunshine'] == true,
        'mouse':     d['barrier']  == true,
        'clipboard': true,
      },
    );
  }

  DeviceType _parseOs(String os) {
    final l = os.toLowerCase();
    if (l.contains('android')) return DeviceType.android;
    if (l.contains('windows')) return DeviceType.windows;
    if (l.contains('linux'))   return DeviceType.linux;
    if (l.contains('ios'))     return DeviceType.ios;
    if (l.contains('macos'))   return DeviceType.macos;
    return DeviceType.unknown;
  }

  String _getOs() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux)   return 'linux';
    if (Platform.isIOS)     return 'ios';
    if (Platform.isMacOS)   return 'macos';
    return 'web';
  }

  Future<String> _getLocalIp() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP() ?? '';
    } catch (_) {
      try {
        final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        for (final i in ifaces) {
          for (final a in i.addresses) {
            if (!a.isLoopback) return a.address;
          }
        }
      } catch (_) {}
      return '';
    }
  }

  Future<String> _getDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('device_name');
    if (saved != null) return saved;
    final os = _getOs();
    return '${os[0].toUpperCase()}${os.substring(1)} Device';
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_id');
    if (id == null) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', id);
    }
    return id;
  }
}

// ── Providers ─────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final devicesStreamProvider = StreamProvider<List<Device>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.when(
    data: (user) => user != null
        ? ref.read(authServiceProvider).watchDevices(user.uid)
        : Stream.value([]),
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});
