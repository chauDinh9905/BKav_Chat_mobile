import 'package:first_flutter/auth/viewmodels/sign_up.dart';
import 'package:first_flutter/chat/viewmodels/chat.dart';
import 'package:first_flutter/core/networks/chat_service.dart';
import 'package:flutter/material.dart';
import 'auth/screens/log_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/networks/auth_service.dart';
import '../auth/viewmodels/log_in.dart';
import 'chat/viewmodels/dashboard.dart';
import 'core/networks/dio_client.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await FlutterDownloader.initialize(
    debug: true, // đặt false khi release
    ignoreSsl: true, // hữu ích khi test với server local chưa có SSL hợp lệ
  );
  final dioClient = DioClient();
  final authService = AuthService(dioClient);
  final chatService = ChatService(dioClient.dio);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              LoginViewModel(
                authService,
              ),
        ),
        ChangeNotifierProvider(create: (_) =>
              SignUpViewModel(authService,
              ),
        ),
        ChangeNotifierProvider(create: (_) =>
            DashboardViewModel(authService,
            ),
        ),
        ChangeNotifierProvider(create: (_) =>
            ChatViewModel(chatService),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home:  LogIn(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String textToShow = 'I Like Flutter';

  void updateText(){
    setState(() {
      textToShow = 'Toi la Chau, lan dau tien toi dung flutter';
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(textToShow)
      ),
      body: Center(/*
        child: ElevatedButton(
           style: ElevatedButton.styleFrom(
             padding: const EdgeInsets.only(left: 30, right: 30),
           ),
          onPressed: updateText,
          child: const Text('Hello'),
        ),*/
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text('Row 1'),
            Text('Row 1'),
            Text('Row 1'),
            Text('Row 1'),
        ],
        ),
      )
    );
  }
}
