import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iFinance - ติดตามการเงิน',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String firstName = '';
  String lastName = '';
  String phone = '';
  bool isLoggedIn = false;

  // ข้อมูล
  double totalNetWorth = 2457800;
  List<BankAccount> banks = [
    BankAccount('SCB', 'XXX-1234567', 1250000, 'ออมทรัพย์'),
    BankAccount('กสิกร', 'YYY-7654321', 890000, 'กระแสรายวัน'),
  ];

  List<Investment> investments = [
    Investment('หุ้น', 'PTT', 450000, 520000, DateTime.now()),
    Investment('กองทุน', 'SCB Equity', 300000, 385000, DateTime.now()),
    Investment('คริปโต', 'Bitcoin', 150000, 210000, DateTime.now()),
  ];

  List<Vehicle> vehicles = [
    Vehicle('Toyota', 'Camry 2.5', 'กข 1234', 850000, DateTime(2023, 5, 10)),
    Vehicle('Honda', 'CR-V', 'คค 5678', 1200000, DateTime(2024, 1, 15)),
  ];

  final currencyFormat = NumberFormat('#,###.##');

  void _login() {
    if (firstName.isNotEmpty && lastName.isNotEmpty && phone.isNotEmpty) {
      setState(() => isLoggedIn = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
      );
    }
  }

  void _addBank() async {
    // Dialog เพิ่มบัญชีธนาคาร (ตัวอย่าง)
    final result = await showDialog<BankAccount>(
      context: context,
      builder: (context) => AddBankDialog(),
    );
    if (result != null) {
      setState(() => banks.add(result));
      _calculateNetWorth();
    }
  }

  void _calculateNetWorth() {
    double sumBanks = banks.fold(0, (p, e) => p + e.balance);
    double sumInvest = investments.fold(0, (p, e) => p + e.currentValue);
    double sumVehicle = vehicles.fold(0, (p, e) => p + e.value);
    setState(() => totalNetWorth = sumBanks + sumInvest + sumVehicle);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text('iFinance', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const Text('ติดตามสถานะทางการเงิน', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
              TextField(
                decoration: const InputDecoration(labelText: 'ชื่อ'),
                onChanged: (v) => firstName = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'นามสกุล'),
                onChanged: (v) => lastName = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
                keyboardType: TextInputType.phone,
                onChanged: (v) => phone = v,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.green,
                ),
                child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 iFinance'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _calculateNetWorth),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => setState(() => isLoggedIn = false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ข้อมูลผู้ใช้
            Card(
              child: ListTile(
                leading: const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                title: Text('$firstName $lastName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(phone),
              ),
            ),

            const SizedBox(height: 20),

            // ยอดรวมสุทธิ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('มูลค่าสุทธิทั้งหมด', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text('${currencyFormat.format(totalNetWorth)} บาท',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // กราฟวงกลม
            const Text('สัดส่วนการลงทุน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: banks.fold(0.0, (p, e) => p + e.balance), color: Colors.blue, title: 'ธนาคาร'),
                    PieChartSectionData(value: investments.fold(0.0, (p, e) => p + e.currentValue), color: Colors.orange, title: 'ลงทุน'),
                    PieChartSectionData(value: vehicles.fold(0.0, (p, e) => p + e.value), color: Colors.purple, title: 'รถ'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // บัญชีธนาคาร
            _buildSection('🏦 บัญชีธนาคาร', banks.map((e) => '${e.bankName} : ${currencyFormat.format(e.balance)} บาท').toList()),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addBank, child: const Text('เพิ่มบัญชีธนาคาร')),

            const SizedBox(height: 20),

            // การลงทุน
            _buildSection('📈 การลงทุน', investments.map((e) => '${e.name} : ${currencyFormat.format(e.currentValue)} บาท').toList()),

            const SizedBox(height: 20),

            // รถยนต์
            _buildSection('🚗 รถยนต์', vehicles.map((e) => '${e.brand} ${e.model} : ${currencyFormat.format(e.value)} บาท').toList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // เพิ่มข้อมูลแบบรวดเร็ว
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มข้อมูลสำเร็จ (ตัวอย่าง)')));
          setState(() {
            investments.add(Investment('ทอง', 'ทองคำแท่ง', 200000, 215000, DateTime.now()));
            _calculateNetWorth();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(title: Text(item)),
            )),
      ],
    );
  }
}

// Models
class BankAccount {
  final String bankName;
  final String accountNumber;
  final double balance;
  final String type;
  BankAccount(this.bankName, this.accountNumber, this.balance, this.type);
}

class Investment {
  final String type;
  final String name;
  final double investedAmount;
  final double currentValue;
  final DateTime date;
  Investment(this.type, this.name, this.investedAmount, this.currentValue, this.date);
}

class Vehicle {
  final String brand;
  final String model;
  final String plate;
  final double value;
  final DateTime purchaseDate;
  Vehicle(this.brand, this.model, this.plate, this.value, this.purchaseDate);
}

// Dialog เพิ่มบัญชีธนาคาร
class AddBankDialog extends StatefulWidget {
  @override
  State<AddBankDialog> createState() => _AddBankDialogState();
}

class _AddBankDialogState extends State<AddBankDialog> {
  final _bankCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _balCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เพิ่มบัญชีธนาคาร'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _bankCtrl, decoration: const InputDecoration(labelText: 'ชื่อธนาคาร')),
          TextField(controller: _accCtrl, decoration: const InputDecoration(labelText: 'เลขบัญชี')),
          TextField(controller: _balCtrl, decoration: const InputDecoration(labelText: 'ยอดเงิน'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
        TextButton(
          onPressed: () {
            final bank = BankAccount(
              _bankCtrl.text,
              _accCtrl.text,
              double.tryParse(_balCtrl.text) ?? 0,
              'ออมทรัพย์',
            );
            Navigator.pop(context, bank);
          },
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}