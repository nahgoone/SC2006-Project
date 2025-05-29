import 'package:flutter/material.dart';
import 'package:flutter_create_test/frontend/components/helper.dart';
import 'package:flutter_create_test/frontend/screens/recycling/manuallyInput/upload_photo_manually_input.dart';

enum MaterialsType { Paper, Glass, Aluminium, Plastics, Metals, Batteries }

class ManuallyInput extends StatefulWidget {
  const ManuallyInput({super.key});

  @override
  State<ManuallyInput> createState() => _ManuallyInputState();
}

class _ManuallyInputState extends State<ManuallyInput> {
  Set<MaterialsType> selectedMaterials = <MaterialsType>{};
  int quantity = 5;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 0) quantity--;
    });
  }

  void validateAndProceed() {
    if (selectedMaterials.isEmpty) {
      showDialogBox(
        context: context,
        title: "Missing Material",
        content: "Please select at least one material type.",
        onPressed: () {},
      );
      return;
    }

    if (quantity <= 0) {
      showDialogBox(
        context: context,
        title: "Invalid Quantity",
        content: "Quantity must be greater than 0.",
        onPressed: () {},
      );
      return;
    }

    if (quantity < selectedMaterials.length) {
      showDialogBox(
        context: context,
        title: "Quantity Too Low",
        content:
            "Quantity must be equal to or more than the number of selected material types (${selectedMaterials.length}).",
        onPressed: () {},
      );
      return;
    }

    // all checks passed — proceed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UploadPhotoManuallyInput(
              quantity: quantity,
              selectedMaterials: selectedMaterials,
            ),
      ),
    ).then((result) {
      if (result == "recycling_done") {
        // Return to Home tab
        DefaultTabController.of(context).animateTo(1); // 2 = Home
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
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  "Materials ",
                  style: TextStyle(color: Colors.white, fontSize: 35),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Wrap(
                spacing: 15.0,
                runSpacing: 5.0,
                children:
                    MaterialsType.values.map((MaterialsType material) {
                      return ChoiceChip(
                        label: Text(
                          material.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        selected: selectedMaterials.contains(material),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              selectedMaterials.add(material);
                            } else {
                              selectedMaterials.remove(material);
                            }
                          });
                        },
                        backgroundColor: Color(0xFF1D4CBA),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              selectedMaterials.contains(material)
                                  ? Color(0xFF002C93)
                                  : Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                          side: BorderSide(color: Colors.white),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
              ),
            ),
            quantitySelector(
              quantity: quantity,
              onIncrement: incrementQuantity,
              onDecrement: decrementQuantity,
            ),
            SizedBox(height: 40),
            customTextButton(text: "Save", onPressed: validateAndProceed),
          ],
        ),
      ),
    );
  }
}
