import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boy_flow/controllers/api_controller.dart';
import 'package:boy_flow/models/wallet_transaction.dart';
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
      api.fetchWalletTransactions().then((_) {
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
            return _buildErrorState(api.walletTransactionError!);
          }

          final transactions = api.walletTransactions;

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionList(transactions);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final api = Provider.of<ApiController>(context, listen: false);
                api.fetchWalletTransactions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No wallet transactions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your wallet transactions will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<WalletTransaction> transactions) {
    return RefreshIndicator(
      onRefresh: () async {
        final api = Provider.of<ApiController>(context, listen: false);
        await api.fetchWalletTransactions();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: transactions.length,
        separatorBuilder: (_, __) =>
            const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: transaction.isCredit
                ? Colors.green.shade100
                : Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.isCredit ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          transaction.message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Balance: ₹${transaction.balanceAfter}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              transaction.formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (transaction.referenceId != null) ...[
              const SizedBox(height: 2),
              Text(
                'Ref: ${transaction.referenceId}',
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Text(
          transaction.amountString,
          style: TextStyle(
            color: transaction.isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showTransactionDetails(WalletTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            label: 'Amount',
            value: transaction.amountString,
            valueColor: transaction.isCredit ? Colors.green : Colors.red,
          ),
          _DetailRow(label: 'Message', value: transaction.message),
          _DetailRow(
            label: 'Balance After',
            value: '₹${transaction.balanceAfter}',
          ),
          _DetailRow(label: 'Date', value: transaction.formattedDate),
          if (transaction.referenceId != null)
            _DetailRow(label: 'Reference ID', value: transaction.referenceId!),
          if (transaction.transactionType != null)
            _DetailRow(label: 'Type', value: transaction.transactionType!),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
