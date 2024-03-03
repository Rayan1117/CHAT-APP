import "dart:io";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class ImagePick extends StatefulWidget {
  const ImagePick({super.key,required this.onPickImage});

  final void Function(File imagePicked) onPickImage;

  @override
  State<ImagePick> createState() => _ImagePickState();
}

class _ImagePickState extends State<ImagePick>{

  File? pickedImageFile;

    void _imagepick() async {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        return;
      }
      setState(() {
        pickedImageFile = File(pickedImage.path);
      });

      widget.onPickImage(pickedImageFile!);
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            backgroundImage: const AssetImage("assets/images/person.jpg"),
            foregroundImage:
                pickedImageFile != null ? FileImage(pickedImageFile!) : null),
        TextButton.icon(
          onPressed: _imagepick,
          icon: const Icon(Icons.image),
          label: const Text("Add Image"),
        )
      ],
    );
  }
}