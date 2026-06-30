import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chat/screens/dashboard.dart';
import '../viewmodels/log_in.dart';
import 'sign_up.dart';


class LogIn extends StatefulWidget{
  const LogIn({super.key});

    @override
      State<LogIn> createState() => LogInState();
}

class LogInState extends State<LogIn> {
  final TextEditingController _taiKhoanController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Lấy ViewModel từ Provider
    final loginViewModel = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('BKav Chat', style: TextStyle(color: Colors.blue)),),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _taiKhoanController, decoration: InputDecoration(labelText: 'Tài khoản')),
              TextField(controller: _matKhauController, decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),

              SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: loginViewModel.isLoading
                    ? null // Nếu đang load thì vô hiệu hóa nút
                    : () async {
                  final success = await context.read<LoginViewModel>().login(
                    _taiKhoanController.text,
                    _matKhauController.text,
                  );

                  if (success) {
                    // Chuyển màn hình
                    print("Dang nhap thanh cong.., dang cbi dieu huong sang dashboar");
                    Navigator.push(context,MaterialPageRoute(builder: (context) => const Dashboard()),);
                  }
                },
                child: loginViewModel.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Đăng nhập'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()),);
                },
                child: Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}