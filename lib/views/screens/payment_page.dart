import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/razorpay_service.dart';

class PaymentPage extends StatefulWidget {
  final String? packageId;
  const PaymentPage({super.key, this.packageId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  String orderId = "";

  // Dynamic package handling
  late String packageId;

  @override
  void initState() {
    super.initState();
    packageId = widget.packageId ?? "6982ee202d43571812168e72";
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);

    if (widget.packageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startPayment();
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> startPayment() async {
    try {
      final order =
          await RazorpayService.createCoinOrder(packageId);

      orderId = order["orderId"];

      var options = {
        'key': order["key"],
        'amount': order["amount"],
        'order_id': orderId,
        'currency': order["currency"],
        'name': 'FriendCircle',
        'description': 'Coin Recharge',
        'prefill': {
          'contact': '9999999999',
          'email': 'test@gmail.com'
        }
      };

      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order Error: $e")),
      );
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final success =
        await RazorpayService.verifyPayment({
      "razorpay_order_id": response.orderId,
      "razorpay_payment_id": response.paymentId,
      "razorpay_signature": response.signature,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Payment Successful 🎉"
            : "Verification Failed ❌"),
      ),
    );
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Payment Failed: ${response.message}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Razorpay Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: startPayment,
          child: const Text("Buy Coins"),
        ),
      ),
    );
  }
}
