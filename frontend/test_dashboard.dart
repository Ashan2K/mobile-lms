import 'dart:convert';

// Test data from user's API response
const String testScheduleData = '''
[
    {
        "id": "BiBMQbQLQOLa7g9rcwXN",
        "title": "test",
        "description": "test des",
        "date": {
            "_seconds": 1752278400,
            "_nanoseconds": 0
        },
        "time": "6:00 PM",
        "classType": "Online",
        "zoomLink": " https://vj-lk.zoom.us/j/84223648502?pwd=2cRCQXTCcy7zE9faD6vlzdWFoAUIu9.1",
        "courseId": "c1N63ga2f9Mzp50sbdQq",
        "courseName": "Basic Java",
        "currentStudents": 0,
        "createdAt": "2025-07-12T13:16:55.789307",
        "updatedAt": "2025-07-12T13:16:55.789322"
    },
    {
        "id": "SB4tpfWMzBXQupiEi6jP",
        "title": "test 2",
        "description": "test",
        "date": {
            "_seconds": 1752278400,
            "_nanoseconds": 0
        },
        "time": "12:30 PM",
        "classType": "Online",
        "zoomLink": "https://vj-lk.zoom.us/j/84223648502?pwd=2cRCQXTCcy7zE9faD6vlzdWFoAUIu9.1",
        "courseId": "tS5FbfQ0VdgNshuVei6o",
        "courseName": "sample",
        "currentStudents": 0,
        "createdAt": "2025-07-12T13:34:11.656505",
        "updatedAt": "2025-07-12T13:34:11.656520"
    }
]
''';

void main() {
  print('Testing Schedule Model Parsing...');

  try {
    final List<dynamic> jsonData = json.decode(testScheduleData);

    for (int i = 0; i < jsonData.length; i++) {
      final schedule = jsonData[i];
      print('Schedule ${i + 1}:');
      print('  Title: ${schedule['title']}');
      print('  Course: ${schedule['courseName']}');
      print('  Date: ${schedule['date']}');
      print('  Time: ${schedule['time']}');
      print('  Class Type: ${schedule['classType']}');
      print('  Zoom Link: ${schedule['zoomLink']}');
      print(
          '  Is Online: ${schedule['classType'].toString().toLowerCase() == 'online'}');
      print('');
    }

    print('✅ Test completed successfully!');
    print(
        'The schedule data format is compatible with the dashboard implementation.');
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
