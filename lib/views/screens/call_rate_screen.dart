import 'package:flutter/material.dart';
import '../../services/razorpay_service.dart';
import 'payment_page.dart';

class MyCallRate extends StatefulWidget {
  const MyCallRate({super.key});

  @override
  State<MyCallRate> createState() => _MyCallRateState();
}

class _MyCallRateState extends State<MyCallRate> {
  List<dynamic> _packages = [];
  bool _isLoading = true;
  String? _error;

  int? selectedIndex;
  int availableTalktime = 0;

  // Controller for the editable price field
  late final TextEditingController _talktimeController;

  @override
  void initState() {
    super.initState();
    _talktimeController = TextEditingController(
      text: availableTalktime.toString(),
    );


    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final packages = await RazorpayService.fetchPackages();
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _talktimeController.dispose();
    super.dispose();
  }

  void _onCardTap(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
        availableTalktime = 0;
        _talktimeController.text = '0';
      } else {
        selectedIndex = index;
        final pkg = _packages[index];
        availableTalktime = pkg['coin'] ?? 0;
        _talktimeController.text = availableTalktime.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color pink1 = Color(0xFFFF4081);
    const Color pink2 = Color(0xFF9C27B0);
    const Color yellow = Color(0xFFF4C200); // pay section
    const double cardRadius = 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar with gradient background
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Talktime',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top area containing the Available Talktime card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.00),
                        blurRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 0.0,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      // middle: labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Talktime',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 10),
                            // REPLACED: Text -> TextField inside container
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: TextField(
                                controller: _talktimeController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: false,
                                      signed: false,
                                    ),
                                textAlign: TextAlign.left,
                                decoration: const InputDecoration(
                                  prefixText: '₹',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 6,
                                  ),
                                  hintText: '0',
                                ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                // Optional: onSubmitted if you want to act when user finishes editing
                                onSubmitted: (value) {
                                  final parsed =
                                      int.tryParse(value.replaceAll(',', '')) ??
                                      0;
                                  setState(() => availableTalktime = parsed);
                                  // If parsed doesn't match any offer, deselect
                                  if (selectedIndex != null &&
                                      _packages[selectedIndex!]['coin'] != parsed) {
                                    selectedIndex = null;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Divider(thickness: 1),
            ),

            const SizedBox(height: 7),

            // "Add Talktime" label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Talktime',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Grid of offers (selectable)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text("Error: $_error"))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _packages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final pkg = _packages[index];
                  final getAmt = pkg['coin'] ?? 0;
                  final payAmt = pkg['amount'] ?? 0;
                  final bool isSelected = selectedIndex == index;

                  // Animated elevation/scale for selected item
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        transform: isSelected
                            ? (Matrix4.identity()..scale(1.03))
                            : Matrix4.identity(),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(
                            color: isSelected
                                ? pink2.withOpacity(0.9)
                                : Colors.grey.shade300,
                            width: isSelected ? 1.6 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isSelected ? 0.12 : 0.03,
                              ),
                              blurRadius: isSelected ? 12 : 4,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top: "Get" and amount
                            Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Get',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹$getAmt',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom yellow Pay bar
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: yellow,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(cardRadius),
                                  bottomRight: Radius.circular(cardRadius),
                                ),
                                // subtle top border for separation
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 0.6,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  const Text(
                                    'Pay',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹$payAmt',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Continue button with gradient
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    // handle continue action
                    // you can read `selectedIndex` and `availableTalktime`
                    if (selectedIndex == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an offer')),
                      );
                      return;
                    }
                    
                    final pkgId = _packages[selectedIndex!]['_id'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(packageId: pkgId),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
