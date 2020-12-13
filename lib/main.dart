import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'termare_ssh.dart';

void main() {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termare SSH',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SshLoginPage(),
    );
  }
}

class SshLoginPage extends StatefulWidget {
  @override
  _SshLoginPageState createState() => _SshLoginPageState();
}

class _SshLoginPageState extends State<SshLoginPage> {
  TextEditingController host = TextEditingController();
  TextEditingController passwd = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.of(context).push<void>(MaterialPageRoute(builder: (context) {
        return TermareSsh(
          hostName: 'nightmare.fun',
          password: 'mys906262255*',
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: host,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xfff7f7f7),
                hintText: '输入主机Host',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            TextField(
              controller: passwd,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xfff7f7f7),
                hintText: '输入主机密码',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context)
                    .push<void>(MaterialPageRoute(builder: (context) {
                  return TermareSsh(
                    hostName: host.text,
                    password: passwd.text,
                  );
                }));
              },
              child: Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}
