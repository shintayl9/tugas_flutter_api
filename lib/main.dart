import 'package:flutter/material.dart';
import 'package:tugas_flutter_api/api_openweather_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      title: 'Shinta flutter_api',
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiOpenweatherService apiService = ApiOpenweatherService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Data Cuaca'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama kota...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchWeather(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<dynamic> weatherData = snapshot.data!;

            if (_searchQuery.isNotEmpty) {
              weatherData = weatherData.where((item) {
                final cityName = item['name'].toString().toLowerCase();
                return cityName.contains(_searchQuery);
              }).toList();
            }

            weatherData.sort((a, b) => a['name'].compareTo(b['name']));

            final double avgTemp = weatherData.isNotEmpty
                ? weatherData
                        .map((item) => item['main']['temp'] as double)
                        .reduce((a, b) => a + b) /
                    weatherData.length
                : 0.0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Suhu rata-rata: ${avgTemp.toStringAsFixed(1)} °C',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData.length,
                    itemBuilder: (context, index) {
                      final item = weatherData[index];
                      final cityName = item['name'];
                      final weatherDesc = item['weather'][0]['description'];
                      final temperature =
                          item['main']['temp'].toStringAsFixed(1);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cityName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text('Cuaca: $weatherDesc'),
                              Text('Suhu: $temperature °C'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
