import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({Key? key, required this.onPickImage}) : super(key: key);

  final void Function(File pickimage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickImageFile;

  void _pickimage() async{
    final pickedImage=await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50,maxWidth: 150);

    if(pickedImage==null){
      return;
    }

    setState(() {
      _pickImageFile=File(pickedImage.path);
    });

    widget.onPickImage(_pickImageFile!);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
            foregroundImage: _pickImageFile!=null ? FileImage(_pickImageFile!):null,
        ),
        TextButton.icon(
          onPressed: _pickimage,
          icon: const Icon(Icons.image),
          label: Text(
            "Add Image",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
