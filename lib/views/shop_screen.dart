import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import '../services/shop_service.dart';
import '../models/user_data.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyService = Provider.of<CurrencyService>(context);
    final userData = currencyService.userData;
    final shopService = ShopService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "차원의 상점",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildGoldDisplay(currencyService.gold),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shopService.items.length,
        itemBuilder: (context, index) {
          final item = shopService.items[index];
          // 가격 계산 (단순화: totalCleared 기반)
          int currentLevel = userData.stats.totalCleared ~/ 10;
          int price = item.getPrice(currentLevel);

          return _buildShopItemCard(context, item, price, userData);
        },
      ),
    );
  }

  Widget _buildGoldDisplay(int gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Text(
            "$gold G",
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItemCard(
    BuildContext context,
    ShopItem item,
    int price,
    UserData userData,
  ) {
    bool canAfford = Provider.of<CurrencyService>(context, listen: false).gold >= price;

    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.white10),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.id == "up_hp" ? Icons.favorite : Icons.bolt,
                color: Colors.cyanAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  "$price G",
                  style: TextStyle(
                    color: canAfford ? Colors.amber : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: canAfford
                      ? () async {
                          bool success = await ShopService().purchaseItem(item, userData);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${item.name} 구매 완료!")),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("구매"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
