import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dartssh/client.dart';
import 'package:dartssh/transport.dart';
import 'package:flutter/material.dart';
import 'package:termare_view/termare_view.dart';

class TermareSsh extends StatefulWidget {
  const TermareSsh({
    Key key,
    this.controller,
    @required this.hostName,
    @required this.password,
    this.loginName = 'root',
  }) : super(key: key);
  final TermareController controller;
  final String hostName;
  final String password;
  // 登录主机的用户名
  final String loginName;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TermareSsh> {
  TermareController controller;
  SSHClient client;

  @override
  void initState() {
    super.initState();
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
    controller = widget.controller ??
        TermareController(
          rowLength: row - 2,
          columnLength: column - 2,
        );

    connect();
  }

  void connect() {
    controller.write('connecting ${widget.hostName}...\n');
    client = SSHClient(
      hostport: Uri.parse('ssh://' + widget.hostName + ':22'),
      login: widget.loginName,
      print: print,
      termWidth: 80,
      termHeight: 25,
      termvar: 'xterm-256color',
      getPassword: () => Uint8List.fromList(utf8.encode(widget.password)),
      response: (SSHTransport transport, String data) {
        controller.write(data);
      },
      success: () {
        controller.write('connected.\n');
      },
      disconnected: () {
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
      controller: controller,
      keyboardInput: (String data) {
        client?.sendChannelData(Uint8List.fromList(utf8.encode(data)));
      },
    );
  }
}
