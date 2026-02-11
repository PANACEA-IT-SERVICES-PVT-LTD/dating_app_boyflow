import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boy_flow/controllers/gift_controller.dart';
import 'package:boy_flow/models/gift.dart';

class GiftSelectionSheet extends StatelessWidget {
  final String femaleUserId;
  final Function(int) onGiftSent; // Callback to update wallet balance in parent

  const GiftSelectionSheet({
    Key? key,
    required this.femaleUserId,
    required this.onGiftSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GiftController()..fetchAllGifts(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: Consumer<GiftController>(
                builder: (context, controller, child) {
                  if (controller.isLoading && controller.gifts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error != null && controller.gifts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: controller.fetchAllGifts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.gifts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No gifts available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return _buildGiftGrid(context, controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select a Gift',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftGrid(BuildContext context, GiftController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.gifts.length,
      itemBuilder: (context, index) {
        final gift = controller.gifts[index];
        return _buildGiftItem(context, gift, controller);
      },
    );
  }

  Widget _buildGiftItem(
    BuildContext context,
    Gift gift,
    GiftController controller,
  ) {
    return GestureDetector(
      onTap: () => _showGiftConfirmation(context, gift, controller),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE3F6), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    gift.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFE3F6),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Color(0xFFFF00CC),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/coins.png",
                        width: 12,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${gift.coin}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGiftConfirmation(
    BuildContext context,
    Gift gift,
    GiftController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Gift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gift.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Send this gift for ${gift.coin} coins?',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close gift selection sheet
                _sendGift(context, gift, controller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF00CC),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendGift(
    BuildContext context,
    Gift gift,
    GiftController controller,
  ) async {
    final response = await controller.sendGiftToFemale(
      femaleUserId: femaleUserId,
      giftId: gift.id,
      giftCoinValue: gift.coin,
    );

    if (response != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      // Update wallet balance in parent screen
      onGiftSent(controller.maleCoinBalance);
    } else if (controller.error != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error!), backgroundColor: Colors.red),
      );
    }
  }
}
