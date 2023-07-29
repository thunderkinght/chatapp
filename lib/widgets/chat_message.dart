import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chat_Message extends StatelessWidget {
  const Chat_Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenicaedUser=FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.
      collection('chat').
      orderBy(
          'createdAt',
          descending: true
      ).
      snapshots(),
      builder: (ctx,chatSnapshot){
        if(chatSnapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty){
          return const Center(
            child: Text("No message Found"),
          );
        }

        if(chatSnapshot.hasError){
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        final loadedMessage=chatSnapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessage.length,
            reverse: true,
            itemBuilder: (ctx,index){
            final chatMessage=loadedMessage[index].data();
            final nextchatMessage=index+1<loadedMessage.length ? loadedMessage[index+1].data():null;
            final currentMessageId=chatMessage['userID'];
            final nextMesageId=nextchatMessage!=null? nextchatMessage['userID']:null;
            final nextUserissame=currentMessageId==nextMesageId;

            if(nextUserissame){
              return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenicaedUser.uid==currentMessageId );
            }
            else{
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenicaedUser.uid==currentMessageId);
            }
            }
        );
      },
    );
  }
}
