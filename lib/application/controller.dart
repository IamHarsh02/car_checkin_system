import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/domain/car_modal.dart';
import 'package:task/domain/database_helper.dart';

class Controller extends GetxController {
  Controller();
  List<Car> cart = [];
  List<Car> checkedInCar = [];
  List<Car> bothCar = [];
  TextEditingController carNumberController = TextEditingController();

  final dbHelper = DatabaseHelper();
  @override
  void onInit() {
    super.onInit();
    carNumberController = TextEditingController();

    getCars();
    addCar(Get.context!);
  }

  deleteCar(String carNumber) async {
    await dbHelper.deleteCar(carNumber);
    getCars();
    update();
  }

  addCar(BuildContext context, {String val = "MH12AB1234"}) async {
    await getCars();
    if (cart.any((existingCar) => existingCar.carNumber == val)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Car with number $val already exists!"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final newCar = Car(
      carNumber: val,
      checkInTime: DateTime.now(),
    );

    await dbHelper.insertCar(newCar.toMap());
    print('Car inserted: ${newCar.carNumber}');
    await getCars();
    update();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Car $val added successfully!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  getCars() async {
    final cars = await dbHelper.getAllCars();
    cart.clear();
    checkedInCar.clear();
    bothCar.clear();
    cars.forEach((carMap) {
      final carModal = Car.fromMap(carMap);
      cart.add(carModal);
      checkedInCar = cart.where((car) => car.checkOutTime == null).toList();
      bothCar = cart.where((car) => car.checkOutTime != null).toList();

      // print('Car: ${carModal.carNumber}, Check-In: ${carModal.checkInTime}, Check-Out: ${carModal.checkOutTime}');
    });
    update();
  }

  updateCheckout({String? val = "", DateTime? checkIn}) async {
    final updatedCar = Car(
      carNumber: val!,
      checkInTime: checkIn!,
      checkOutTime: DateTime.now(),
    );
    await dbHelper.updateCar(updatedCar.toMap());
    getCars();
    print('Car updated: ${updatedCar.carNumber}');
  }

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
}
