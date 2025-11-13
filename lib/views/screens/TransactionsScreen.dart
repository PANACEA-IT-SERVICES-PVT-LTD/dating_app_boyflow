import 'package:Boy_flow/views/screens/call_rate_screen.dart';
import 'package:flutter/material.dart';
import 'package:Boy_flow/widgets/TransactionItem.dart'; 

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> demoData = const [
    {
      "title": "Deposit",
      "subtitle": "22-Oct 13:44",
      "amount": 99,
      "isPositive": true,
    },
    {
      "title": "Recharge",
      "subtitle": "20-Oct 09:22",
      "amount": 49,
      "isPositive": false,
    },
    {
      "title": "Bonus Added",
      "subtitle": "18-Oct 16:15",
      "amount": 25,
      "isPositive": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF00CC),
                Color(0xFF9A00F0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Talktime Transactions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // ✅ Navigate to Talktime Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCallRate(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "₹99",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: demoData.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white24, height: 1),
                    itemBuilder: (context, index) {
                      final item = demoData[index];
                      return TransactionItem(
                        title: item['title'] as String,
                        subtitle: item['subtitle'] as String,
                        amount: item['amount'] as num,
                        isPositive: item['isPositive'] as bool,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${item['title']} transaction tapped!'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
