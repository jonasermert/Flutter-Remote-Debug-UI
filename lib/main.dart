// main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const RemoteDebuggerApp());
}

class RemoteDebuggerApp extends StatelessWidget {
  const RemoteDebuggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Remote Debugger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({super.key});

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  final List<String> logs = [];
  final List<RemoteHost> savedHosts = [
    RemoteHost('Pi Devboard', 'pi', '192.168.1.100', '54321', '54321'),
    RemoteHost('Linux Android Lab', 'dev', '10.0.0.42', '5555', '5555'),
  ];

  RemoteHost? selectedHost;
  Process? _flutterProcess;
  String devToolsUrl = '';

  void log(String message) {
    setState(() => logs.add(message));
  }

  Future<void> startDebugging() async {
    if (selectedHost == null) {
      log('❗ Kein Host ausgewählt.');
      return;
    }

    final host = selectedHost!;
    log('🔗 Erstelle SSH Tunnel zu ${host.host}:${host.remotePort} ...');

    final sshResult = await Process.run(
      'ssh',
      ['-f', '-N', '-L', '${host.localPort}:127.0.0.1:${host.remotePort}', '${host.user}@${host.host}'],
    );

    if (sshResult.exitCode != 0) {
      log('❌ SSH fehlgeschlagen: ${sshResult.stderr}');
      return;
    }

    log('🚀 Starte flutter run remote...');

    await Process.run(
      'ssh',
      ['${host.user}@${host.host}', 'flutter', 'run', '--host-vmservice-port=${host.remotePort}', '--disable-service-auth-codes'],
    );

    log('🪄 SSH & App-Start erfolgreich. Starte flutter attach ...');

    _flutterProcess = await Process.start(
      'flutter',
      ['attach', '--debug-port=${host.localPort}'],
      runInShell: true,
    );

    _flutterProcess?.stdout.transform(SystemEncoding().decoder).listen((line) {
      log(line);
      final uriMatch = RegExp(r'(http://127.0.0.1:\d+/\?uri=.*)').firstMatch(line);
      if (uriMatch != null) {
        setState(() => devToolsUrl = uriMatch.group(1)!);
      }
    });

    _flutterProcess?.stderr.transform(SystemEncoding().decoder).listen((line) {
      log('⚠️ $line');
    });

    _flutterProcess?.exitCode.then((code) {
      log('🛑 Flutter attach beendet mit Code $code');
    });
  }

  Future<void> adbForward() async {
    if (selectedHost == null) return;
    final host = selectedHost!;
    log('📡 ADB Forward von tcp:${host.localPort} zu tcp:${host.remotePort} ...');
    final adb = await Process.run('adb', ['forward', 'tcp:${host.localPort}', 'tcp:${host.remotePort}']);
    log(adb.stdout);
    if (adb.stderr.toString().isNotEmpty) log('⚠️ ${adb.stderr}');
  }

  void stopFlutterAttach() {
    _flutterProcess?.kill(ProcessSignal.sigint);
    log('🛑 flutter attach gestoppt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Remote Debug UI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<RemoteHost>(
              value: selectedHost,
              hint: const Text('Wähle Remote Host'),
              onChanged: (host) => setState(() => selectedHost = host),
              items: savedHosts.map((host) {
                return DropdownMenuItem(
                  value: host,
                  child: Text(host.label),
                );
              }).toList(),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: startDebugging,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Connect & Attach'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: adbForward,
                  icon: const Icon(Icons.usb),
                  label: const Text('ADB Forward'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: stopFlutterAttach,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                const SizedBox(width: 10),
                if (devToolsUrl.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(devToolsUrl)),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('DevTools öffnen'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: ListView(
                  children: logs.map((line) => Text(line, style: const TextStyle(fontSize: 12))).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemoteHost {
  final String label;
  final String user;
  final String host;
  final String remotePort;
  final String localPort;

  RemoteHost(this.label, this.user, this.host, this.remotePort, this.localPort);
}
