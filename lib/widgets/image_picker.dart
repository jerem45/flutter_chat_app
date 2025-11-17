import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.userImageSelected});
  final ValueChanged<File?> userImageSelected;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePicker();
  }
}

class _UserImagePicker extends State<UserImagePicker> {
  File? _userImageSelected;
  void _pickImage() async {
    final userImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (userImage == null) {
      return;
    }

    setState(() {
      _userImageSelected = File(userImage.path);
      widget.userImageSelected(_userImageSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          foregroundImage: _userImageSelected != null ? FileImage(_userImageSelected!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          label: Text(
            "Ajouter une image de profil",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          icon: Icon(Icons.image_search, color: Theme.of(context).colorScheme.error),
        ),
      ],
    );
  }
}
