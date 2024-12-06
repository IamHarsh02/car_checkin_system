import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/application/controller.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  bool showTextField = false; // To toggle the visibility of the TextField
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? carNumberValidator(String? value) {
    // Regular expression to validate car number format (e.g., MH12AB1234)
    final carNumberRegExp = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$');

    // If the car number doesn't match the regex, return an error message
    if (value == null || value.isEmpty) {
      return 'Car number is required';
    } else if (!carNumberRegExp.hasMatch(value)) {
      return 'Invalid car number format';
    }
    return null; // Return null if validation passes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Car"),
      ),
      body: GetBuilder<Controller>(
          init: Controller(),
          builder: (ct) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  if (!showTextField)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showTextField = true;
                        });
                      },
                      child: const Text("Add Car"),
                    ),
                  if (showTextField)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),
                          TextFormField(
                            // validator: carNumberValidator,
                            controller: ct.carNumberController,
                            decoration: const InputDecoration(
                              labelText: "Car Number",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {},
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return "Car number cannot be empty";
                            //   }
                            //   return null;
                            // },
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Handle adding the car here
                                ct.getCars();
                                if (ct.carNumberValidator(
                                        ct.carNumberController.text) ==
                                    null) {
                                  ct.addCar(context,
                                      val: ct.carNumberController.text);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(ct.carNumberValidator(
                                            ct.carNumberController.text)!)),
                                  );
                                }
                                setState(() {
                                  showTextField = false;
                                  ct.carNumberController.clear();
                                });
                              }

                              Get.back();
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }
}
