// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
import 'widget_test.mocks.dart' as mocks;

void main() {
  late mocks.MockClient mockClient;

  setUp(() {
    mockClient = mocks.MockClient();
  });

  group('Login Tests', () {
    // test('Successful login should return UserModel', () async {
    //   // Arrange
    //   final mockResponse = {
    //     'user': {
    //       'id': '1',
    //       'fname': 'John',
    //       'lname': 'Doe',
    //       'email': 'john@example.com',
    //       'role': 'student',
    //     },
    //     'token': 'mock_token'
    //   };

    //   when(mockClient.post(
    //     Uri.parse('http://localhost:3000/api/login'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: anyNamed('body'),
    //   )).thenAnswer((_) async => http.Response(
    //         '{"user": ${mockResponse['user']}, "token": "${mockResponse['token']}"}',
    //         200,
    //       ));

    //   // Act
    //   final result = await AuthService.login('john@example.com', 'password123');

    //   // Assert
    //   expect(result, isNotNull);
    //   expect(result?.email, 'john@example.com');
    //   expect(result?.fname, 'John');
    //   expect(result?.lname, 'Doe');
    //   expect(result?.role.toString(), 'UserRole.student');
    // });

    test('Failed login should return null', () async {
      // Arrange
      when(mockClient.post(
        Uri.parse('http://localhost:5000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Invalid credentials', 401));

      // Act
      final result =
          await AuthService.login('wrong@email.com', 'wrongpassword');

      // Assert
      expect(result, isNull);
    });

    test('Network error should return null', () async {
      // Arrange
      when(mockClient.post(
        Uri.parse('http://localhost:3000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      // Act
      final result = await AuthService.login('test@email.com', 'password123');

      // Assert
      expect(result, isNull);
    });
  });
}
