import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/manually_input.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/review_photo_maunally_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';

class UploadPhotoManuallyInput extends StatefulWidget {
  final int quantity;
  final Set<MaterialsType> selectedMaterials;
  const UploadPhotoManuallyInput({
    super.key,
    required this.quantity,
    required this.selectedMaterials,
  });

  @override
  State<UploadPhotoManuallyInput> createState() =>
      _UploadPhotoManuallyInputState(quantity, selectedMaterials);
}

class _UploadPhotoManuallyInputState extends State<UploadPhotoManuallyInput> {
  File? _image;
  final int quantity;
  final Set<MaterialsType> selectedMaterials;
  _UploadPhotoManuallyInputState(this.quantity, this.selectedMaterials);

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReviewPhotoMaunallyInput(
                  image: _image!,
                  quantity: quantity,
                  selectedMaterials: selectedMaterials,
                ),
          ),
        ).then((result) {
          if (result == "recycling_done") {
            Navigator.pop(context, "recycling_done");
          }
        });
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReviewPhotoMaunallyInput(
                  image: _image!,
                  quantity: quantity,
                  selectedMaterials: selectedMaterials,
                ),
          ),
        ).then((result) {
          if (result == "recycling_done") {
            Navigator.pop(context, "recycling_done");
          }
        });
      } else {
        print('No image taken.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF002C93),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 210,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Color(0xFF0B4EEC),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 26.0),
                child: Text(
                  "Upload a photo of your tra\$h!🗑️  ",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    "Regulations require you to upload a photo of your recyclables next to any recycling bin to earn points. Once you reach 100 points, you can redeem them for credits! Each recyclable item counts as one point!",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 310,
                height: 150,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 194, 194, 194),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Icon(Icons.photo, color: Colors.white, size: 30),
                    ),
                    Text(
                      "Select file",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('OR', style: TextStyle(color: Colors.white)),
            SizedBox(height: 20),
            customTextButton(
              text: "Open Camera & Take a Photo",
              onPressed: _takePhoto,
            ),
          ],
        ),
      ),
    );
  }
}
