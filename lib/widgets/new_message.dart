import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class New_Message extends StatefulWidget {
  const New_Message({Key? key}) : super(key: key);

  @override
  State<New_Message> createState() => _New_MessageState();
}

class _New_MessageState extends State<New_Message> {
  final _messageController=TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }

  void _submit() async {
    final enterendmessage=_messageController.text;
    if(enterendmessage.trim().isEmpty){
      return;
    }

    _messageController.clear();

    final user=FirebaseAuth.instance.currentUser!;
    final userData= await FirebaseFirestore.instance.
    collection('users').
    doc(user.uid).
    get();

    FirebaseFirestore.instance.collection('chat').add({
      'text':enterendmessage,
      'createdAt':Timestamp.now(),
      'userID':user.uid,
      'username':userData.data()!['username'],
      'userImage':userData.data()!['imageUrl']
    });

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15,right: 1,bottom: 14),
      child: Row(
        children: [
            Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    labelText: "Send a Message...",
                  ),
                ),
            ),
          IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
