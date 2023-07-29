import 'package:chatapp/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Future<void> setupPushNotification() async{
    final fcm=FirebaseMessaging.instance;

    await fcm.requestPermission();

    final token=await fcm.getToken();
    print(token);
    FirebaseMessaging.onBackgroundMessage((message) async{
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Payload: ${message.data}');
    });

  }

  // Future<void> handleBackgroundMessage(RemoteMessage message)async{
  //   print('Title: ${message.notification?.title}');
  //   print('Body: ${message.notification?.body}');
  //   print('Payload: ${message.data}');
  // }

  @override
  void initState() {
    // TODO: implement initState
    setupPushNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlutterChat"),
        actions: [
          IconButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: Chat_Message()),
          New_Message(),
        ],
      ),
    );
  }
}
