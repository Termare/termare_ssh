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
    this.onBell,
  }) : super(key: key);
  final TermareController controller;
  final String hostName;
  final String password;
  // 登录主机的用户名
  final String loginName;
  final SSHClient sshClient;
  final void Function(SSHClient sshClient) successClient;
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
      controller = TermareController();
      controller.setFontSize(11);
    } else {
      controller = widget.controller;
    }

    connect();
  }

  void connect() {
    if (widget.sshClient == null)
      controller.write('connecting ${widget.hostName}...\n');
    final TermSize size = TermSize.getTermSize(window.physicalSize);
    // 行数
    final int row = size.row;
    // 列数
    final int column = size.column;
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
          termWidth: column,
          termHeight: row,
          termvar: 'xterm-256color',
          getPassword: () => Uint8List.fromList(utf8.encode(widget.password)),
          response: (SSHTransport transport, String data) {
            // transport.
            // print('data -> $data ');
            if (connected) {
              controller.autoScroll = true;
              controller.write(data);
            }
          },
          success: () {
            connected = true;
            controller.write('connected success.\n');
            widget.successClient(client);
            // 有点不优雅，实现controller写进终端，跟write不一样
            controller.clear();
            controller.input = (String data) {
              client?.sendChannelData(Uint8List.fromList(utf8.encode(data)));
            };
            controller.sizeChanged = (TermSize size) {
              client?.setTerminalWindowSize(size.column, size.row);
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
      controller: controller,
      keyboardInput: controller.input,
    );
  }
}
