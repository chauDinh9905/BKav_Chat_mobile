
import 'package:flutter/material.dart';

class ErrorLogIn extends StatefulWidget{
  const ErrorLogIn({super.key});

  @override
  State<ErrorLogIn> createState() => ErrorLogInState();
}

class ErrorLogInState extends State<ErrorLogIn>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('BKav Chat', style: TextStyle(color: Colors.blue))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Tài khoản'),
            ),
            Center(
               child: TextField(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Mật khẩu'),
            ),
            Center(
              child: TextField(),
            ),
            SizedBox(height: 50),
            SizedBox( child: Text('Bạn nhập sai tên tài khoản hoặc mật khẩu', style: TextStyle(color: Colors.red), textAlign: TextAlign.center,)),
            SizedBox(height: 50),
            ElevatedButton(onPressed: (){print('Thông tin không hợp lệ');}, style: ElevatedButton.styleFrom(padding: EdgeInsets.only(left: 100, right: 100), backgroundColor: Colors.lightBlue), child: Text('Đăng nhập', style: TextStyle(color: Colors.white))),
            SizedBox(height: 10),
            ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.only(left: 105, right: 105)), child: Text('Đăng ký', style: TextStyle(color: Colors.black))),
            ]
        )
      ),
      backgroundColor: Colors.white,
    );
  }
}