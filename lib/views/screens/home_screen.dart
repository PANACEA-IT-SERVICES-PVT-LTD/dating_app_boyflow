import 'package:Boy_flow/views/screens/profile_gallery_screen.dart';
import 'package:Boy_flow/views/screens/female_profile_screen.dart';
import 'package:Boy_flow/models/female_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:Boy_flow/api_service/api_endpoint.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int walletAmount = 1000; // Example initial amount
  final List<FemaleUser> users = [
    FemaleUser(
      id: '1',
      name: 'Sophie92',
      age: 22,
      bio:
          'Family and parenting, Society and politics. Cooking, Writing. Cricket.',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
  ];

  Future<void> rechargeWallet(int amount) async {
    print('[Recharge] Function entered with amount: $amount');
    try {
      final url = Uri.parse(
        ApiEndPoints.baseUrls + ApiEndPoints.maleWalletRecharge,
      );
      print('[Recharge] Calling: ' + url.toString());
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );
      print('[Recharge] API response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[Recharge] Decoded response: $data');
        if (data['success'] == true) {
          int? newAmount;
          if (data['data'] != null && data['data']['amount'] != null) {
            newAmount = data['data']['amount'];
          }
          setState(() {
            if (newAmount != null) {
              walletAmount = newAmount;
            } else {
              walletAmount += amount;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wallet recharged successfully!')),
          );
        } else {
          print('[Recharge] API returned success=false or missing data');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recharge failed: ${data['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      } else {
        print('[Recharge] API error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API error: ${response.statusCode}')),
        );
      }
    } on SocketException catch (e) {
      print('[Recharge] Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Please check your connection')),
      );
    } on http.ClientException catch (e) {
      print('[Recharge] Client error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
    } catch (e, st) {
      print('[Recharge] Exception: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recharge error: $e')));
    }
  }

  void showRechargePopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final TextEditingController amountController = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Recharge Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    Navigator.pop(context);
                    rechargeWallet(amount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount')),
                    );
                  }
                },
                child: const Text('Recharge'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRandomPopup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Limited Time Offer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'FLAT 80% Off',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '250 Coins',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '₹ 250',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Rs 50',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print('Random popup: Add 250 Coins button pressed');
                Navigator.pop(context);
                rechargeWallet(250); // Call the API for 250 coins
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Add 250 Coins'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  walletAmount.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FemaleProfileScreen(user: user),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Age: ${user.age}'),
                        Text(
                          user.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: showRechargePopup,
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Recharge'),
            backgroundColor: Colors.pinkAccent,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () {
              rechargeWallet(250);
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('Random'),
            backgroundColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
