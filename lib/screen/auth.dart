import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase=FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form=GlobalKey<FormState>();
  bool _islogin=true;
  var _isAuth=false;

  var _enterendemail='';
  var _enterendpassword='';
  var _enterendusername='';
  File? _pickedImage;

  void _submit() async{
    setState(() {
      _isAuth=true;
    });

    final isValid=_form.currentState!.validate();
    if(!isValid || !_islogin && _pickedImage==null){
      return;
    }
    _form.currentState!.save();

    if(_islogin){
      final userCredential= await _firebase.signInWithEmailAndPassword(
          email: _enterendemail,
          password: _enterendpassword
      );
    }
    else{
      try{
        final userCredential=await _firebase.createUserWithEmailAndPassword(
            email: _enterendemail,
            password: _enterendpassword);
        final storageRef=FirebaseStorage.instance.
          ref().
          child("user_image").
          child("${userCredential.user!.uid}.jpg");

        await storageRef.putFile(_pickedImage!);
        final imageURL=await storageRef.getDownloadURL();
        print(imageURL);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'username':_enterendusername,
              'email': _enterendemail,
              'imageUrl': imageURL,
            });
      }
      on FirebaseAuthException catch(err){
        if(err.code=='email-already-on-use'){

        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message?? "Authenication Failure"),
        ),
        );

      }
      setState(() {
        _isAuth=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  right: 20,
                  left: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(!_islogin) UserImagePicker(onPickImage: (pickimage) {
                            _pickedImage=pickimage;
                          },),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email Address"
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value){
                              if(value==null || value.trim().isEmpty || !value.contains('@')){
                                return "Please enter a valid email Address";
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enterendemail=value!;
                            },
                          ),
                          if(!_islogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Username"
                            ),
                            enableSuggestions: false,
                            validator: (value){
                              if(value==null || value.isEmpty|| value.trim().length<4){
                                return "Username must be atleast 4 character long";
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enterendusername=value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Password"
                            ),
                            obscureText: true,
                            validator: (value){
                              if(value==null || value.trim().length<6){
                                return "Password must be atleast 6 character long";
                              }
                              return null;
                            },
                            onSaved: (value){
                              _enterendpassword=value!;
                            },
                          ),
                          const SizedBox(height: 10,),
                          if(_isAuth)
                            const CircularProgressIndicator(),
                          if(!_isAuth)
                          ElevatedButton(
                              onPressed: _submit,
                              child: Text(_islogin? "Login":"Signup")
                          ),
                          if(!_isAuth)
                          TextButton(
                              onPressed: (){
                                setState(() {
                                  _islogin=!_islogin;
                                });
                              },
                              child: Text(_islogin? "Create a Account": "I already have an account"))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
