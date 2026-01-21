import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Boy_flow/controllers/api_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetched) {
      final api = Provider.of<ApiController>(context, listen: false);
      api.fetchMaleWalletTransactions().then((_) {
        if (api.walletTransactionError == null &&
            api.walletTransactions.isNotEmpty) {
          Fluttertoast.showToast(
            msg: "Wallet transactions loaded successfully!",
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
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
            "Wallet Transactions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Consumer<ApiController>(
        builder: (context, api, _) {
          if (api.isWalletTransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (api.walletTransactionError != null) {
            return Center(
              child: Text(
                api.walletTransactionError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          final txs = api.walletTransactions;
          if (txs.isEmpty) {
            return const Center(
              child: Text(
                'No wallet transactions found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: txs.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white24, height: 1),
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
              return ListTile(
                leading: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
                title: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Balance: $balance\n$formatted'),
                isThreeLine: true,
                trailing: Text(
                  (isCredit ? '+' : '-') + amount.toString(),
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
