import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(source: source);
  if (pickedFile != null) {
    // Handle the picked image
  }
}

@override
Widget build(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Profile'),
        ),
        ListTile(
          title: const Text('Select from Gallery'),
          onTap: () => pickImage(ImageSource.gallery),
        ),
        ListTile(
          title: const Text('Take a Picture'),
          onTap: () => pickImage(ImageSource.camera),
        ),
      ],
    ),
  );
}
