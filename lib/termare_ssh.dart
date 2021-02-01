import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dartssh/client.dart';
import 'package:dartssh/transport.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:termare_view/termare_view.dart';

class TermareSsh extends StatefulWidget {
  const TermareSsh({
    Key key,
    this.controller,
    @required this.hostName,
    @required this.password,
    this.loginName = 'root',
    this.sshClient,
    this.successClient,
    this.bottomBar,
    this.onBell,
  }) : super(key: key);
  final TermareController controller;
  final String hostName;
  final String password;
  // 登录主机的用户名
  final String loginName;
  final SSHClient sshClient;
  final void Function(SSHClient sshClient) successClient;
  final Widget bottomBar;
  final void Function() onBell;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TermareSsh> {
  TermareController controller;
  SSHClient client;
  bool connected = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      final Size size = window.physicalSize;
      print(size);
      print(window.devicePixelRatio);
      final double screenWidth = size.width / window.devicePixelRatio;
      final double screenHeight = size.height / window.devicePixelRatio;
      // 行数
      final int row = screenHeight ~/ TermareStyles.termux.letterHeight;
      // 列数
      final int column = screenWidth ~/ TermareStyles.termux.letterWidth;
      print('< row : $row column : $column>');
      controller = TermareController(
        rowLength: row - 2,
        columnLength: column - 2,
      );
      controller.setFontSize(11);
    } else {
      controller = widget.controller;
    }

    connect();
  }

  void connect() {
    if (widget.sshClient == null)
      controller.write('connecting ${widget.hostName}...\n');
    final Size size = window.physicalSize;
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    // 行数
    final int row = screenHeight ~/ TermareStyles.termux.letterHeight;
    // 列数
    final int column = screenWidth ~/ TermareStyles.termux.letterWidth;
    print('ssh client 初始化的 row为$row column为$column');
    // 抓异常
    client = widget.sshClient ??
        SSHClient(
          hostport: Uri.parse('ssh://' + widget.hostName + ':22'),
          login: widget.loginName,
          print: (String value) {
            print('print value ->$value');
            controller.write(value + '\n');
          },
          acceptHostFingerprint: (int a, Uint8List uint8list) {
            print(a);
            print(uint8list);
            return true;
          },
          termWidth: 49,
          termHeight: 49,
          termvar: 'xterm-256color',
          getPassword: () => Uint8List.fromList(utf8.encode(widget.password)),
          response: (SSHTransport transport, String data) {
            // transport.
            // print('data -> $data ');
            if (connected) {
              controller.write(data);
            }
          },
          success: () {
            connected = true;
            controller.write('connected success.\n');
            widget.successClient(client);
            // 有点不优雅，实现controller写进终端，跟write不一样
            controller.clear();
            controller.keyboardInput = (String data) {
              client?.sendChannelData(Uint8List.fromList(utf8.encode(data)));
            };
            setState(() {});
          },
          disconnected: () {
            widget.successClient(null);
            controller.write('disconnected.');
          },
        );
  }

  void onInput(String input) {
    // client?.sendChannelData(utf8.encode(input));
  }

  @override
  Widget build(BuildContext context) {
    return TermareView(
      onBell: widget.onBell,
      bottomBar: widget.bottomBar,
      controller: controller,
      keyboardInput: controller.keyboardInput,
    );
  }
}
