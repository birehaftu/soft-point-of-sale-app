import 'package:flutter/material.dart';
import 'Admin.dart';
import 'Agent.dart';
import 'api/LogIn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Soft Point of Sale',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'ACT Soft Point of Sale'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // STATE - variable
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userName, password;

  Future<void> _handleButtonPress() async {
    if (((userName?.isEmpty??true) || (password?.isEmpty??true))==false) {
    //print("$userName $password");
      try {
        final data =await LogIn(userName!, password);
          if(data["role"]=="Admin" && data["status"]=="Active") {
            ScaffoldMessenger.of(context)
                .showSnackBar(
                const SnackBar(content: Text("LogIn Successful! Admin")));
            runApp(const Admin());
          }else if(data["role"]=="Agent" && data["status"]=="Active"){
            ScaffoldMessenger.of(context)
                .showSnackBar(
                const SnackBar(content: Text("LogIn Successful! Agent")));
            runApp(Agent(userId: data["userId"].toString(),));
            //runApp(ExampleApp());

          } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
              const SnackBar(content: Text("Invalid username or password!")));
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar( SnackBar(content: Text('Error: $e')));
        //print('Error: $e');
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar( SnackBar(content: Text('unknown Error : $e')));
        //print('unknown Error : $e');
      }

    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User Name and password can''t be empty!')));
      //print('User Name and password can''t be empty!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scrollbar(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                "User LogIn",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("User Name"),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.name,
                onChanged: (String value) {
                  userName = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Password"),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (String value) {
                  password = value;
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: _handleButtonPress,
                child: const Text('LogIn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
