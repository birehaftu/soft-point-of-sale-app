import 'package:flutter/material.dart';
import 'api/MakeTransaction.dart';
class Agent extends StatelessWidget {
  const Agent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Soft Point of Sale Card Association',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'ACT Soft Point of Sale Card Association'),
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
  @override
  Future<void> initState() async {
    super.initState();
    await loadPage();
  }

  Future<void> loadPage() async {
    try {
      final data = await GetListOfCards();
      if (data != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
            const SnackBar(content: Text("LogIn Successful! Admin")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
            const SnackBar(content: Text("There are no registered accounts!")));
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      //print('Error: $e');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('unknown Error : $e')));
      //print('unknown Error : $e');
    }
  }

  String? userName, password;

  Future<void> _handleButtonPress() async {
    if (((userName?.isEmpty ?? true) || (password?.isEmpty ?? true)) == false) {
      //print("$userName $password");
      try {
        final data = await GetListOfCards();
        if (data == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
              const SnackBar(content: Text("Card Association done!")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
              const SnackBar(
                  content: Text("Card Association failed try again!")));
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        //print('Error: $e');
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('unknown Error : $e')));
        //print('unknown Error : $e');
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
          content: Text('User Name and password can''t be empty!')));
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Account Card Association",
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
                child: const Text('Associate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
