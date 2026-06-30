import 'package:flutter/material.dart';

class ErrorSignUp extends StatefulWidget{
  const ErrorSignUp({super.key});

  @override
  State<ErrorSignUp> createState() => ErrorSignUpState();
}

class ErrorSignUpState extends State<ErrorSignUp>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('BKav Chat', style: TextStyle(color: Colors.blue))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 200, child: Text('Tạo tài khoản', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w100)),),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Nhập lại mật khẩu'),
            ),
            Center(
              child: TextField(),
            ),
            SizedBox(height: 40),
            Center(
              child: SizedBox(child: Text('Tài khoản đã tồn tại !', style: TextStyle(color: Colors.red)))
            ),
            SizedBox(height: 40),
            ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(padding: EdgeInsets.only(left: 100, right: 100), backgroundColor: Colors.lightBlue), child: Text('Tạo tài khoản', style: TextStyle(color: Colors.white)),)
          ],
        )
      ),
        backgroundColor: Colors.white,
    );
  }
}