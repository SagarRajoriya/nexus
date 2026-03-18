import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';

class DevicesNotifier extends StateNotifier<List<Device>> {
  DevicesNotifier() : super(demoDevices);

  void updateStatus(String id, DeviceStatus status) {
    state = [for (final d in state) if (d.id == id) d.copyWith(status: status) else d];
  }

  void addOrUpdate(Device device) {
    final idx = state.indexWhere((d) => d.id == device.id || d.ip == device.ip);
    if (idx < 0) {
      state = [...state, device];
    } else {
      state = [for (int i = 0; i < state.length; i++) i == idx ? device : state[i]];
    }
  }

  void addDevice(Device device) => addOrUpdate(device);

  void removeDevice(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void markAllOffline() {
    state = [for (final d in state) d.copyWith(status: DeviceStatus.offline)];
  }
}

final devicesProvider = StateNotifierProvider<DevicesNotifier, List<Device>>(
  (ref) => DevicesNotifier(),
);

final onlineDevicesProvider = Provider<List<Device>>(
  (ref) => ref.watch(devicesProvider).where((d) => d.status == DeviceStatus.online).toList(),
);
