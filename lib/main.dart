import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task/application/controller.dart';
import 'package:task/presentation/add_car_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'domain/car_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Car Check In & Check Out System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GetBuilder<Controller>(
        init: Controller(),
        builder: (ct) {
          return Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Checked In & CheckOut Car"),
                      const SizedBox(height: 50),
                      // Render list of both checked-in and checked-out cars
                      _buildCarList(ct.bothCar, "No Cars CheckedIn & Out", ct),
                      const SizedBox(height: 50),
                      const Text("Checked In"),
                      const SizedBox(height: 10),
                      // Render list of checked-in cars
                      _buildCarList(ct.checkedInCar, "No CheckedIn Cars", ct),
                      const SizedBox(height: 20),
                      // Add Car Button
                      ElevatedButton(
                        onPressed: () {
                          Get.to(AddCarScreen());
                        },
                        child: const Text("Add Car"),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _sendFeedback();
                },
                child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Icon(
                      Icons.feedback,
                      color: Colors.blueAccent,
                      size: 50.0,
                    )),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarList(List<Car> carList, String emptyMessage, Controller ct) {
    if (carList.isEmpty) {
      return Text(emptyMessage);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: carList.length,
      itemBuilder: (context, index) {
        final car = carList[index];
        String formattedDateTimeIn =
            DateFormat('dd/MM/yyyy hh:mm').format(car.checkInTime);
        String? formattedDateTimeOut;
        if (car.checkOutTime != null) {
          formattedDateTimeOut =
              DateFormat('dd/MM/yyyy hh:mm').format(car.checkOutTime!);
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const Icon(
              Icons.directions_car,
              color: Colors.blue,
              size: 40,
            ),
            title: Text(
              "Car Number: ${car.carNumber}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Check-In: $formattedDateTimeIn"),
                if (formattedDateTimeOut != null)
                  Text("Check-Out: $formattedDateTimeOut"),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "check_in") {
                  print("Check In pressed for ${car.carNumber}");
                } else if (value == "check_out") {
                  ct.updateCheckout(
                      val: car.carNumber, checkIn: car.checkInTime);
                  print("Check Out pressed for ${car.carNumber}");
                } else if (value == "delete") {
                  ct.deleteCar(car.carNumber);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "check_out",
                  child: Text("Check Out"),
                ),
                const PopupMenuItem<String>(
                  value: "delete",
                  child: Text("Delete"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _sendFeedback() async {
  final String email = 'patareharsh@gmail.com'; // Replace with your email
  final String subject = 'Feedback for Car Check-In Check-Out System';
  final String body =
      'Hi,\n\nI would like to provide the following feedback:\n\n';

  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=$subject&body=${Uri.encodeComponent(body)}',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch $emailUri';
  }
}
