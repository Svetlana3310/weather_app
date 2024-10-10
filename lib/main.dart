import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('uk', ''), // Ukrainian
      ],
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  List<String> _cities = ["Київ", "Запоріжжя", "Львів", "Харків"];
  String dropdownValue = 'Київ';
  String city = "Київ";
  String temperature = "";
  String condition = "";
  String iconUrl = "";
  bool isLoading = true;
  TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  Future<void> fetchWeather(String city) async {
    final apiKey = '0987012a955f41ba361868000139565a';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = "${data['main']['temp']}°C";
        condition = data['weather'][0]['description'];
        iconUrl =
        "http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png";
        isLoading = false;
      });
    } else {
      setState(() {
        temperature = "Не вдалося отримати погоду";
        condition = "";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Погода в $city'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Loading Indicator
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newCity) {
                if (newCity != null) {
                  setState(() {
                    dropdownValue = newCity;
                    city = newCity;
                    isLoading = true;
                    fetchWeather(city);
                  });
                }
              },
              items: _cities
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Введіть місто',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_cityController.text.isNotEmpty) {
                        setState(() {
                          city = _cityController.text;
                          isLoading = true;
                          fetchWeather(city);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Температура: $temperature',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Опис: $condition',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            iconUrl.isNotEmpty
                ? Image.network(iconUrl)
                : Container(), // Weather icon
          ],
        ),
      ),
    );
  }
}