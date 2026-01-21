import 'package:Boy_flow/views/screens/call_rate_screen.dart';
import 'package:flutter/material.dart';
import 'package:Boy_flow/controllers/api_controller.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      final api = Provider.of<ApiController>(context, listen: false);
      api.fetchMaleCoinTransactions().then((_) {
        if (api.transactionError == null && api.coinTransactions.isNotEmpty) {
          Fluttertoast.showToast(
            msg: "Coin transactions loaded successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      });
      _fetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pink = const Color(0xFFFF00CC);
    final purple = const Color(0xFF9A00F0);
    final pastel = const Color(0xFFFDE7F3);
    final darkText = const Color(0xFF222222);
    final debitColor = Colors.red;
    final creditColor = Colors.green;
    final tagStyle = BoxDecoration(
      color: pastel,
      borderRadius: BorderRadius.circular(12),
    );
    final tagTextStyle = const TextStyle(
      fontFamily: 'ComicNeue',
      fontSize: 15,
      color: Color(0xFF222222),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pink,
        title: const Text(
          "My Transactions",
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Consumer<ApiController>(
        builder: (context, api, _) {
          if (api.isTransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (api.transactionError != null) {
            return Center(
              child: Text(
                api.transactionError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'ComicNeue',
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          final txs = api.coinTransactions;
          if (txs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'ComicNeue',
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: txs.length,
            itemBuilder: (context, index) {
              final tx = txs[index];
              final isCredit =
                  (tx['action'] ?? '').toString().toLowerCase() == 'credit';
              final isDebit =
                  (tx['action'] ?? '').toString().toLowerCase() == 'debit';
              final amount = tx['amount'] ?? 0;
              final message = tx['message'] ?? '';
              final balance = tx['balanceAfter'] ?? '';
              final createdAt = tx['createdAt'] ?? '';
              DateTime? dt;
              String formatted = createdAt;
              try {
                dt = DateTime.parse(createdAt);
                formatted =
                    '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              } catch (_) {}
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: pastel, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? creditColor.withOpacity(0.15)
                                  : debitColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              isCredit ? 'Credit' : 'Debit',
                              style: TextStyle(
                                color: isCredit ? creditColor : debitColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ComicNeue',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatted,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontFamily: 'ComicNeue',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            (isCredit ? '+' : '-') + amount.toString(),
                            style: TextStyle(
                              color: isCredit ? creditColor : debitColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'ComicNeue',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'ComicNeue',
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: tagStyle,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text('Balance: $balance', style: tagTextStyle),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: pink, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.message, color: Color(0xFFFF00CC)),
                label: const Text(
                  'Say Hi',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Color(0xFFFF00CC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text(
                  'Call',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
