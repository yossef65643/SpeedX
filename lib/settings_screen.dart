import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد مكتبة SharedPreferences
import 'car_type_screen.dart'; // تأكد من استيراد صفحة CarTypeScreen
import 'oil_cost_screen.dart'; // إضافة استيراد صفحة OilCostScreen
import 'home_screen.dart'; // استيراد شاشة الوضع الداكن
import 'home_screen2.dart'; // استيراد شاشة الوضع الفاتح

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = true; // متغير للتحكم في وضع الألوان

  @override
  void initState() {
    super.initState();
    _loadColorMode(); // تحميل حالة الوضع عند بدء الشاشة
  }

  // دالة لتحميل حالة الوضع من SharedPreferences
  Future<void> _loadColorMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true; // افتراض أن الوضع داكن إذا لم يكن مخزناً
    });
  }

  // دالة لحفظ حالة الوضع في SharedPreferences
  Future<void> _saveColorMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        iconTheme: IconThemeData(color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.directions_car, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Car Type', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarTypeScreen()),
              ).then((result) {
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Oil Cost', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OilCostScreen()),
              ).then((result) {
                if (result != null) {
                  Navigator.pop(context, result);
                }
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Clear', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              // يمكنك إضافة وظيفة هنا إذا لزم الأمر
            },
          ),
          ListTile(
            leading: Icon(Icons.brightness_2, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Color Mode', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              setState(() {
                isDarkMode = !isDarkMode; // تبديل الوضع
                _saveColorMode(isDarkMode); // حفظ الحالة الجديدة
              });

              // الانتقال إلى الشاشة المناسبة بناءً على الوضع
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WillPopScope(
                    onWillPop: () async => false, // منع العودة
                    child: isDarkMode ? HomeScreen() : HomeScreen2(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Help', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              // يمكنك إضافة وظيفة هنا إذا لزم الأمر
            },
          ),
          ListTile(
            leading: Icon(Icons.close, color: isDarkMode ? Colors.lightBlueAccent : Colors.black),
            title: Text('Exit', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
            onTap: () {
              Navigator.pop(context); // للعودة إلى الصفحة الرئيسية
            },
          ),
        ],
      ),
    );
  }
}
