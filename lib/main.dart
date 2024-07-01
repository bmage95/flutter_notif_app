import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Notifications Demo'),
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _reminderOption = 0; // 0: at time, 5: 5 mins before, 10: 10 mins before, 15: 15 mins before

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _configureLocalTimeZone();
    _initializeNotifications();
    _requestPermissions();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Get the current device's time zone name
    final String timeZoneName = await tz.TZDateTime.now(tz.UTC).timeZoneName;
    // Set the local time zone to IST
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }


  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _createNotificationChannel();
  }

  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_notifications', // id
      'Daily reminders', // name
      description: 'Channel for daily reminder notifications', // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
12
  Future<void> _requestPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    status = await Permission.scheduleExactAlarm.status;
    if (!status.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _scheduleNotification() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    scheduledDate = scheduledDate.subtract(Duration(minutes: _reminderOption));

    // Debugging print statements
    print('Current time: $now');
    print('Scheduled time before adjustment: $scheduledDate');

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Final scheduled time: $scheduledDate');

    for (int i = 0; i < 7; i++) {
      final scheduledDateForDay = scheduledDate.add(Duration(days: i));
      print('Scheduling notification for: $scheduledDateForDay');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'Reminder',
        'This is your scheduled reminder!',
        scheduledDateForDay,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_notifications',
            'Daily reminders',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _scheduleSimpleNotification() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = now.add(const Duration(minutes: 1));

    print('Scheduling simple notification for: $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Simple Reminder',
      'This is your simple reminder!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'simple_notifications',
          'Simple reminders',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected time: ${_selectedTime.format(context)}',
            ),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('Select Time'),
            ),
            const SizedBox(height: 20),
            const Text('Remind me:'),
            ListTile(
              title: const Text('At time'),
              leading: Radio<int>(
                value: 0,
                groupValue: _reminderOption,
                onChanged: (int? value) {
                  setState(() {
                    _reminderOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('5 minutes before'),
              leading: Radio<int>(
                value: 5,
                groupValue: _reminderOption,
                onChanged: (int? value) {
                  setState(() {
                    _reminderOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('10 minutes before'),
              leading: Radio<int>(
                value: 10,
                groupValue: _reminderOption,
                onChanged: (int? value) {
                  setState(() {
                    _reminderOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('15 minutes before'),
              leading: Radio<int>(
                value: 15,
                groupValue: _reminderOption,
                onChanged: (int? value) {
                  setState(() {
                    _reminderOption = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _requestPermissions();
                await _scheduleNotification();
              },
              child: const Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}