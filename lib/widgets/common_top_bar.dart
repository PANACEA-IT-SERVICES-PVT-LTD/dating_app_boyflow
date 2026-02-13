import 'package:flutter/material.dart';

class CommonTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? coinBalance;
  final VoidCallback? onCoinTap;
  final bool showCoin;
  final List<Widget>? actions;

  const CommonTopBar({
    Key? key,
    required this.title,
    this.coinBalance,
    this.onCoinTap,
    this.showCoin = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (showCoin)
            GestureDetector(
              onTap: onCoinTap,
              child: Row(
                children: [
                  Image.asset("assets/coins.png", width: 22, height: 22),
                  const SizedBox(width: 4),
                  Text(
                    (coinBalance ?? 0).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          if (actions != null) ...actions!,
        ],
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
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
