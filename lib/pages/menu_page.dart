import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'day_statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctorlist.dart';
// import 'summary.dart'; // Import the SummaryAnalyzer class

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int touchedIndex = -1;
  String username = " ";
  String overallSummary = "You're doing great! Keep it up."; // Default message

  void getUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        setState(() {
          username = userData.exists ? userData['username'] ?? 'User' : 'User';
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  void _handleBarTouched(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayStatisticsPage(values[index], dates[index]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUsername();
    // loadSummary(); // Load summary message during initialization
  }

  // void loadSummary() async {
  //   try {
  //     // Get the overall summary message from the SummaryAnalyzer class
  //     String? summary = await SummaryAnalyzer.getOverallSummary();

  //     setState(() {
  //       overallSummary =
  //           summary ?? "Default summary message"; // Provide a default value
  //     });
  //   } catch (e) {
  //     print('Error loading summary: $e');
  //   }
  // }

  List<String> dates = [
    '2023-01-01',
    '2023-01-02',
    '2023-01-03',
    '2023-01-04',
    '2023-01-05',
    '2023-01-06',
    '2023-01-07',
    '2023-01-08',
    '2023-01-09',
    '2023-01-10'
  ];

  List<Map<String, double>> values = [
    {
      'Depression': 7,
      'Anxiety': 4,
      'BiPolar': 2,
      'Loneliness': 9,
      'Frustration': 5
    },
    {
      'Depression': 3,
      'Anxiety': 8,
      'BiPolar': 5,
      'Loneliness': 2,
      'Frustration': 7
    },
    {
      'Depression': 9,
      'Anxiety': 1,
      'BiPolar': 7,
      'Loneliness': 5,
      'Frustration': 3
    },
    {
      'Depression': 2,
      'Anxiety': 6,
      'BiPolar': 4,
      'Loneliness': 8,
      'Frustration': 1
    },
    {
      'Depression': 8,
      'Anxiety': 3,
      'BiPolar': 1,
      'Loneliness': 7,
      'Frustration': 9
    },
    {
      'Depression': 5,
      'Anxiety': 2,
      'BiPolar': 9,
      'Loneliness': 4,
      'Frustration': 6
    },
    {
      'Depression': 4,
      'Anxiety': 7,
      'BiPolar': 6,
      'Loneliness': 3,
      'Frustration': 8
    },
    {
      'Depression': 6,
      'Anxiety': 5,
      'BiPolar': 8,
      'Loneliness': 1,
      'Frustration': 4
    },
    {
      'Depression': 6,
      'Anxiety': 5,
      'BiPolar': 8,
      'Loneliness': 1,
      'Frustration': 4
    },
    {
      'Depression': 7,
      'Anxiety': 4,
      'BiPolar': 2,
      'Loneliness': 9,
      'Frustration': 5
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD1A9FF),
        title: Text('MindCare Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/pfp.png'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$username',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                height: 400,
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    // groupsSpace: 20,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.purpleAccent,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${dates[group.x.toInt()]}',
                            TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      touchCallback:
                          (FlTouchEvent event, BarTouchResponse? response) {
                        if (response != null && response.spot != null) {
                          setState(() {
                            touchedIndex = response.spot!.touchedBarGroupIndex;
                          });
                          if (touchedIndex != -1) {
                            _handleBarTouched(touchedIndex);
                          }
                        } else {
                          setState(() {
                            touchedIndex = -1;
                          });
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (double value) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < dates.length) {
                            double averageValue = values[value.toInt()]
                                    .values
                                    .reduce((a, b) => a + b) /
                                values[value.toInt()].length;
                            return averageValue.toStringAsFixed(1);
                          }
                          return '';
                        },
                      ),
                      rightTitles: SideTitles(showTitles: false),
                      leftTitles: SideTitles(showTitles: false),
                      topTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      dates.length,
                      (index) {
                        double averageValue =
                            values[index].values.reduce((a, b) => a + b) /
                                values[index].length;
                        final isTouched = touchedIndex == index;
                        return BarChartGroupData(
                          x: index,
                          barsSpace: 0,
                          barRods: [
                            BarChartRodData(
                              y: averageValue,
                              colors: [
                                isTouched
                                    ? Colors.purpleAccent.withOpacity(1.0)
                                    : Colors.purpleAccent.withOpacity(0.6),
                              ],
                              width: 25,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Overall Summary:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                overallSummary,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorList()),
                  );
                },
                child: Text('Book Appointment with Psychiatrist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
