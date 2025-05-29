import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/manually_input.dart';
import 'package:flutter_create_test/backend/services/firestore_service.dart';
import 'package:flutter_create_test/backend/models/recycling_history.dart';
import 'package:flutter_create_test/backend/models/user_session.dart';

class ReviewPhotoMaunallyInput extends StatefulWidget {
  final File image;
  final int quantity;
  final Set<MaterialsType> selectedMaterials;
  const ReviewPhotoMaunallyInput({
    required this.selectedMaterials,
    required this.image,
    required this.quantity,
    super.key,
  });

  @override
  State<ReviewPhotoMaunallyInput> createState() =>
      _ReviewPhotoMaunallyInputState(image, quantity, selectedMaterials);
}

class _ReviewPhotoMaunallyInputState extends State<ReviewPhotoMaunallyInput> {
  final File image;
  final int quantity;
  final Set<MaterialsType> selectedMaterials;
  _ReviewPhotoMaunallyInputState(
    this.image,
    this.quantity,
    this.selectedMaterials,
  );
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Color(0xFF0B4EEC),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Container(
                height: 400,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(image),
                ),
              ),
            ),
            SizedBox(height: 30),
            customTextButton(
              onPressed: () async {
                // Get current time
                final now = DateTime.now();
                final formattedDate =
                    '${now.day.toString().padLeft(2, '0')}/'
                    '${now.month.toString().padLeft(2, '0')}/'
                    '${now.year.toString().substring(2)}';
                final formattedTime =
                    '${now.hour.toString().padLeft(2, '0')}:'
                    '${now.minute.toString().padLeft(2, '0')}';

                final userId =
                    UserSession().uid!; // assume it's always non-null
                final firestoreService = FirestoreService();

                final history = RecyclingHistory(
                  title: 'Image Processing',
                  date: formattedDate,
                  time: formattedTime,
                  rewardsEarned: -1,
                  iconName: 'refresh',
                );

                await firestoreService.addRecyclingHistory(userId, history);

                showDialogBox(
                  context: context,
                  title: "Success!",
                  content:
                      "We will be reviewing your picture and your points will be credited within 3-5 working days!",
                  onPressed: () {
                    int count = 0;
                    Navigator.popUntil(context, (route) => count++ == 3);
                  },
                );
              },

              text: "Upload",
            ),
          ],
        ),
      ),
    );
  }
}
