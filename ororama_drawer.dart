import 'package:database/index/ororama_archive.dart';
import 'package:database/index/ororama_chart.dart';
import 'package:database/index/ororama_home.dart';
import 'package:database/index/ororama_purchase.dart';
import 'package:database/index/ororamalist.dart';
import 'package:database/index/productsO.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _rating = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Submit Feedback',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 800),
      ), // Animate title
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (text.length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 200),
              ), // Animate name field
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  labelText: 'Feedback',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 5,
                maxLength: 4096,
                textInputAction: TextInputAction.done,
                validator: (String? text) {
                  if (text == null || text.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (text.length > 4096) {
                    return 'Feedback must be 4096 characters or less';
                  }
                  return null;
                },
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 400),
              ), // Animate feedback field
              const SizedBox(height: 16),
              const Text(
                'Rate your experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 600),
              ), // Animate rating label
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow.shade700,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ).animate().scale(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 800),
              ), // Animate stars
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 1000),
        ), // Animate Cancel
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              if (_rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rating')),
                );
                return;
              }

              try {
                final collection = FirebaseFirestore.instance.collection(
                  'feedback',
                );
                await collection.add({
                  'timestamp': FieldValue.serverTimestamp(),
                  'name': _nameController.text.trim(),
                  'feedback': _feedbackController.text.trim(),
                  'rating': _rating,
                });
                if (mounted) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: const Text(
                            'Thank You!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 800),
                          ),
                          content: const Text(
                            'We appreciate your feedback.',
                            style: TextStyle(fontSize: 16),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 1000),
                            delay: const Duration(milliseconds: 200),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Close"),
                            ).animate().fadeIn(
                              duration: const Duration(milliseconds: 1000),
                              delay: const Duration(milliseconds: 400),
                            ),
                          ],
                        ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  String errorMessage;
                  if (e is FirebaseException) {
                    switch (e.code) {
                      case 'permission-denied':
                        errorMessage =
                            'Permission denied. Check Firestore rules.';
                        break;
                      case 'unavailable':
                        errorMessage =
                            'Network error. Please check your connection.';
                        break;
                      default:
                        errorMessage = 'Error: ${e.message ?? e.toString()}';
                    }
                  } else {
                    errorMessage = 'Unexpected error: $e';
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
                }
                print('Detailed Error: $e');
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Send"),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 1000),
        ), // Animate Send
      ],
    );
  }
}

class NotificationService {
  static Future<void> initNotification() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'shopping_reminder',
        channelName: 'Shopping Reminders',
        channelDescription: 'Reminders for shopping tasks',
        importance: NotificationImportance.High,
        defaultColor: const Color(0xFF9D50BB),
        ledColor: Colors.white,
      ),
    ]);

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> scheduleShoppingReminder({
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'shopping_reminder',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledDateTime,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }
}

Widget darwerOrorama(BuildContext context) {
  return Drawer(
    elevation: 10,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/shop.gif',
                    height: 80,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    "Ororama",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: "Home",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OroramaHome()),
                      ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.search,
                  title: "Products",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Productso()),
                      ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.list_alt,
                  title: "Items",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Ororamalist()),
                      ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_cart,
                  title: "Purchase",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OroramaPurchase(),
                        ),
                      ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.archive,
                  title: "Archive",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OroramaArchive(),
                        ),
                      ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.alarm_on,
                  title: "Reminder",
                  onTap: () => _showScheduleReminderDialog(context),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.compare,
                  title: "Comparison",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OroramaChart()),
                      ),
                ),
                Divider(height: 20, thickness: 1, color: Colors.grey.shade400),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info,
                  title: "About Us",
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.feedback,
                  title: "Send Feedback",
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const FeedbackDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: ListTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 28).animate().scale(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ), // Zoom-in and zoom-out animation
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
      hoverColor: Colors.blueAccent.withOpacity(0.1),
      splashColor: Colors.blueAccent.withOpacity(0.3),
    ),
  );
}

void _showAboutDialog(BuildContext context) {
  Navigator.of(context).pop(); // Close the drawer
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AboutUsDialog();
    },
  );
}

void _showScheduleReminderDialog(BuildContext context) {
  DateTime? selectedDateTime;

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Softer corners
                side: BorderSide(
                  color: Colors.blueAccent.withOpacity(0.2),
                  width: 2,
                ), // Subtle borders
              ),
              elevation: 10, // Add shadow for depth
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Schedule Your Shopping Day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // Light background for content
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Plan your shopping day with a reminder!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 200),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.blueAccent,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black87,
                                  ),
                                  dialogTheme: DialogThemeData(
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blueAccent,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.calendar_today, size: 20),
                        label: const Text(
                          'Pick Date & Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().scale(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 400),
                      ),
                      if (selectedDateTime != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.event,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Set for: ${selectedDateTime!.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 1000),
                          delay: const Duration(milliseconds: 600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 800),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (selectedDateTime != null) {
                      NotificationService.scheduleShoppingReminder(
                        title: 'Shopping Day Reminder',
                        body: 'Shopping day! Don’t forget your list.',
                        scheduledDateTime: selectedDateTime!,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder scheduled successfully!'),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a date and time'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.alarm_add, size: 20),
                  label: const Text(
                    'Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 800),
                ),
              ],
            );
          },
        ),
  );
}

class AboutUsDialog extends StatelessWidget {
  // Team member data
  final List<Map<String, String>> teamMembers = [
    {
      "name": "Michael I. Nacaya",
      "role": "Developer",
      "image": "assets/images/mi.jpg",
      "facebook": "https://www.facebook.com/michael.nacaya.9",
      "contact": "639354786152",
    },
    {
      "name": "Domingo E. Ancog Jr.",
      "role": "Designer",
      "image": "assets/images/d.jpg",
      "facebook": "https://www.facebook.com/profile.php?id=61556766518511",
      "contact": "639354786152",
    },
  ];

  AboutUsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        "About Us",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Optional Intro Section
            Text(
              "We’re a dedicated team behind your shopping app!",
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 200),
            ),
            SizedBox(height: 20),
            // Team Members
            ...teamMembers.asMap().entries.map((entry) {
              int index = entry.key;
              var member = entry.value;
              return TeamMemberCard(
                member: member,
                animationDelay: 400 + (index * 600), // Staggered animation
              );
            }),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text("Close"),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 1000),
          delay: const Duration(milliseconds: 1800),
        ),
      ],
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final Map<String, String> member;
  final int animationDelay;

  const TeamMemberCard({
    super.key,
    required this.member,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Semantics(
            label: "Profile picture of ${member['name']}",
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(member['image']!),
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
            ).animate().scale(
              duration: const Duration(milliseconds: 1000),
              delay: Duration(milliseconds: animationDelay),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: Colors.blue,
                size: 18,
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: Duration(milliseconds: animationDelay + 200),
              ),
              SizedBox(width: 5),
              Text(
                member['name']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: Duration(milliseconds: animationDelay + 200),
              ),
            ],
          ),
          Text(
            member['role']!,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 1000),
            delay: Duration(milliseconds: animationDelay + 300),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.facebook, size: 20),
                label: Text("Facebook"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _launchUrl(context, member['facebook']!),
              ).animate().fadeIn(
                duration: const Duration(milliseconds: 1000),
                delay: Duration(milliseconds: animationDelay + 400),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => _launchUrl(context, "tel:${member['contact']}"),
                child: Text(
                  "+${member['contact']}",
                  style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 1000),
                  delay: Duration(milliseconds: animationDelay + 600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not launch $url")));
    }
  }
}
