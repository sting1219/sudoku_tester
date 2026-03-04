// lib/views/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_data.dart';
import '../models/item_model.dart';

class InventoryScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onUpdate;

  const InventoryScreen({
    super.key,
    required this.userData,
    required this.onUpdate,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "인벤토리",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: widget.userData.inventory.isEmpty
          ? Center(
              child: Text(
                "가방이 비어 있습니다.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.userData.inventory.length,
              itemBuilder: (context, index) {
                final item = widget.userData.inventory[index];
                return _buildItemCard(item);
              },
            ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(_getItemIcon(item.type), color: Colors.amberAccent),
                Text("x${item.count}", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                item.description,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => _useItem(item),
                child: const Text("사용", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.potion:
        return Icons.local_hospital;
      case ItemType.mana:
        return Icons.bolt;
      case ItemType.equipment:
        return Icons.shield;
      case ItemType.misc:
        return Icons.category;
    }
  }

  void _useItem(Item item) {
    setState(() {
      if (item.type == ItemType.misc && item.id == 'atk_buff') {
        widget.userData.baseAttackPower += item.value;
        item.count--;
      }
      // 포션 등은 전투 화면에서 주로 사용되지만 여기서도 가능하게 구현
      if (item.count <= 0) {
        widget.userData.inventory.remove(item);
      }
    });
    widget.onUpdate();
    LocalStorageService.saveUserData(widget.userData);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${item.name}을(를) 사용했습니다.")));
  }
}
