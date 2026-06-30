import 'package:flutter/material.dart';

class ErrorConnectionNetwork extends StatefulWidget{
  const ErrorConnectionNetwork({super.key});

  @override
  State<ErrorConnectionNetwork> createState() => ErrorConnectionNetworkState();
}

class ErrorConnectionNetworkState extends State<ErrorConnectionNetwork>{
   @override
  Widget build(BuildContext context){
      return Scaffold(
        body: Center(
          child: SizedBox(height: 300, width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(minimumSize: Size(5,5), side: BorderSide.none), child: Text('x', style: TextStyle(fontSize: 7),)),
              ),
              Center(
                child: Text('Kết nối mạng không ổn định, bạn vui lòng thử lại sau', style: TextStyle(fontSize: 10),),
              ),
              SizedBox(height: 5),
              OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(minimumSize: Size(10, 10), padding: EdgeInsets.only(left: 10, right: 10), backgroundColor: Colors.blue), child: Text('Ok', style: TextStyle(fontSize: 7, color: Colors.white),)),
            ],
          )
          )
        )
      );
   }
}