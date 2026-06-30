import 'package:first_flutter/auth/viewmodels/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SignUp extends StatefulWidget{
  const SignUp({super.key});

  @override
  State<SignUp> createState() => SignUpState();
}

class SignUpState extends State<SignUp>{
  final TextEditingController _tenHienThiController = TextEditingController();
  final TextEditingController _taiKhoanController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final TextEditingController _nhapLaiMatKhauController = TextEditingController();
  String errorText = '';
  @override
  Widget build(BuildContext context){
    final signUpViewModel = context.watch<SignUpViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('BKav Chat', style: TextStyle(color: Colors.blue)),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 200, child: Text('Tạo tài khoản', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300,))),
            TextField(controller: _tenHienThiController, decoration: InputDecoration(labelText: 'Tên hiển thị'),),
            TextField(controller: _taiKhoanController, decoration: InputDecoration(labelText: 'Tài khoản'),),
            TextField(controller: _matKhauController, decoration: InputDecoration(labelText: 'Mật khẩu'),),
            TextField(controller: _nhapLaiMatKhauController, decoration: InputDecoration(labelText: 'Nhập lại mật khẩu'),),
            SizedBox(height: 50),
            ElevatedButton(
                 onPressed: signUpViewModel.isLoading?null:()async{
                   if(_matKhauController.text != _nhapLaiMatKhauController.text) {
                     setState(() {
                       errorText = 'Mật khẩu không trùng nhau';
                     });
                     return;
                      }
                   else if(_tenHienThiController.text.isEmpty || _taiKhoanController.text.isEmpty
                          || _matKhauController.text.isEmpty || _nhapLaiMatKhauController.text.isEmpty){
                     setState(() {
                       errorText = 'Thông tin chưa được nhập đầy đủ';
                     });
                     return;
                   }
                   setState(() {
                     signUpViewModel.isLoading = true;
                   });
                   final success = await signUpViewModel.signup(_tenHienThiController.text, _taiKhoanController.text, _matKhauController.text);
                   if(!mounted) return;
                   setState(() {
                     signUpViewModel.isLoading = false;
                   });
                   if (success) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng ký thành công!')));
                     Navigator.pop(context); // Quay về màn hình Login
                   } else {
                     setState(() {
                       errorText = 'Tên đăng nhập đã tồn tại!';
                     });
                     return;
                   }
                   print(errorText);
                 }, style: ElevatedButton.styleFrom(padding: EdgeInsets.only(left: 100, right: 100), backgroundColor: Colors.lightBlue),
            child: Text('Tạo tài khoản', style: TextStyle(color: Colors.white)),),
            SizedBox(height: 20),
            Center(
                child: SizedBox(child: Text(errorText, style: TextStyle(color: Colors.red)))
            ),
          ],
        )
      ),
      backgroundColor: Colors.white,
    );
  }
}