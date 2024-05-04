import 'package:flutter/material.dart';

class ScheduleAppointment extends StatefulWidget {
  final String doctorName;
  final String clinicName;
  final String address;
  final String imageUrl;

  ScheduleAppointment({
    required this.doctorName,
    required this.clinicName,
    required this.address,
    required this.imageUrl,
  });

  @override
  _ScheduleAppointmentState createState() => _ScheduleAppointmentState();
}

class _ScheduleAppointmentState extends State<ScheduleAppointment> {
  String selectedTimeSlot = '';
  String appointmentMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Appointment - ${widget.doctorName}'),
        backgroundColor: Color.fromARGB(255, 160, 74, 203),
      ),
      backgroundColor: Color.fromARGB(255, 215, 174, 236),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundImage: AssetImage(widget.imageUrl),
            ),
            SizedBox(height: 16.0),
            Text(
              'Doctor Name: ${widget.doctorName}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Clinic Name: ${widget.clinicName}'),
            SizedBox(height: 8.0),
            Text('Address: ${widget.address}'),
            SizedBox(height: 16.0),
            Text(
              'Select Available Timing:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            buildTimeSlotTable(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedTimeSlot.isNotEmpty) {
                  String message =
                      'Appointment Scheduled for ${widget.doctorName} on $selectedTimeSlot';
                  print(message);
                  setState(() {
                    appointmentMessage = message;
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please select a time slot.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Schedule Appointment',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16.0),
            // Display the appointment message
            if (appointmentMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  appointmentMessage,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeSlotTable() {
    return Table(
      children: [
        buildTimeSlotRow('Monday', '9 AM - 5 PM'),
        buildTimeSlotRow('Tuesday', '10 AM - 6 PM'),
        // Add more rows as needed
      ],
    );
  }

  TableRow buildTimeSlotRow(String day, String timeSlot) {
    return TableRow(
      children: [
        buildSelectableTimeSlot(day, timeSlot),
      ],
    );
  }

  Widget buildSelectableTimeSlot(String day, String timeSlot) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeSlot = '$day $timeSlot';
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedTimeSlot == '$day $timeSlot'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          '$day\n$timeSlot',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selectedTimeSlot == '$day $timeSlot'
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
