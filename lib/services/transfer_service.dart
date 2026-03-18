import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/device.dart';

enum TransferStatus { pending, active, done, error }
enum TransferDirection { outgoing, incoming }

class TransferItem {
  final String id;
  final String fileName;
  final int totalBytes;
  int sentBytes;
  TransferStatus status;
  final TransferDirection direction;
  final String deviceName;
  String? error;

  TransferItem({
    required this.id,
    required this.fileName,
    required this.totalBytes,
    this.sentBytes = 0,
    this.status = TransferStatus.pending,
    required this.direction,
    required this.deviceName,
  });

  double get progress => totalBytes > 0 ? sentBytes / totalBytes : 0;

  String get sizeLabel {
    if (totalBytes < 1024) return '${totalBytes}B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalBytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}

class TransferNotifier extends StateNotifier<List<TransferItem>> {
  TransferNotifier() : super([]);
  ServerSocket? _server;

  void _add(TransferItem t) => state = [t, ...state];

  TransferItem _applyAndReturn(TransferItem t, void Function(TransferItem) fn) {
    fn(t);
    return t;
  }

  void _update(String id, void Function(TransferItem) fn) {
    state = [
      for (final t in state)
        if (t.id == id) _applyAndReturn(t, fn) else t
    ];
  }

  Future<void> startServer() async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, 5050);
      _server!.listen(_handleIncoming);
    } catch (_) {}
  }

  Future<void> _handleIncoming(Socket socket) async {
    final chunks = <int>[];
    String? id;
    String? fileName;
    int? totalBytes;
    IOSink? fileSink;
    int received = 0;

    await for (final chunk in socket) {
      if (fileName == null) {
        chunks.addAll(chunk);
        final newlineIdx = chunks.indexOf(10);
        if (newlineIdx < 0) continue;
        final headerBytes = chunks.sublist(0, newlineIdx);
        final rest = chunks.sublist(newlineIdx + 1);
        final header = jsonDecode(utf8.decode(headerBytes)) as Map<String, dynamic>;
        id = header['id'] as String;
        fileName = header['name'] as String;
        totalBytes = header['size'] as int;

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/nexus_received/$fileName');
        await file.parent.create(recursive: true);
        fileSink = file.openWrite();

        _add(TransferItem(
          id: id, fileName: fileName, totalBytes: totalBytes!,
          direction: TransferDirection.incoming,
          deviceName: socket.remoteAddress.address,
          status: TransferStatus.active,
        ));

        if (rest.isNotEmpty) {
          fileSink.add(rest);
          received += rest.length;
          _update(id, (t) => t.sentBytes = received);
        }
      } else {
        fileSink?.add(chunk);
        received += chunk.length;
        _update(id!, (t) => t.sentBytes = received);
      }
    }

    await fileSink?.flush();
    await fileSink?.close();
    socket.destroy();
    if (id != null) _update(id, (t) => t.status = TransferStatus.done);
  }

  Future<void> sendFile(File file, Device target) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final stat = await file.stat();
    final item = TransferItem(
      id: id,
      fileName: file.uri.pathSegments.last,
      totalBytes: stat.size,
      direction: TransferDirection.outgoing,
      deviceName: target.name,
      status: TransferStatus.active,
    );
    _add(item);

    try {
      final socket = await Socket.connect(target.ip, target.port,
          timeout: const Duration(seconds: 5));

      final header = jsonEncode({'id': id, 'name': item.fileName, 'size': stat.size});
      socket.write('$header\n');

      int sent = 0;
      await for (final chunk in file.openRead()) {
        socket.add(chunk);
        sent += chunk.length;
        _update(id, (t) => t.sentBytes = sent);
        await Future.delayed(Duration.zero);
      }

      await socket.flush();
      await socket.close();
      _update(id, (t) => t.status = TransferStatus.done);
    } catch (e) {
      _update(id, (t) {
        t.status = TransferStatus.error;
        t.error = e.toString();
      });
    }
  }

  void removeTransfer(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }
}

final transferProvider =
StateNotifierProvider<TransferNotifier, List<TransferItem>>(
      (ref) {
    final n = TransferNotifier();
    n.startServer();
    return n;
  },
);