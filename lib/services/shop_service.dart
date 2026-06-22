import '../models/user_data.dart';
import 'currency_service.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int basePrice;
  final int priceIncrement;
  final Function(UserData) onPurchase;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.priceIncrement,
    required this.onPurchase,
  });

  int getPrice(int currentLevel) {
    return basePrice + (currentLevel * priceIncrement);
  }
}

class ShopService {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  final List<ShopItem> items = [
    ShopItem(
      id: "up_hp",
      name: "체력 강화",
      description: "기본 최대 HP를 20 증가시킵니다.",
      basePrice: 500,
      priceIncrement: 300,
      onPurchase: (userData) {
        userData.baseMaxHp += 20;
      },
    ),
    ShopItem(
      id: "up_atk",
      name: "공격력 강화",
      description: "기본 공격력을 5 증가시킵니다.",
      basePrice: 500,
      priceIncrement: 400,
      onPurchase: (userData) {
        userData.baseAttackPower += 5;
      },
    ),
  ];

  /// 아이템 구매를 시도합니다.
  Future<bool> purchaseItem(ShopItem item, UserData userData) async {
    // 유저 데이터 내부에 레벨 정보를 저장할 공간이 필요함 (여기선 간단히 업그레이드 횟수라고 가정)
    // 실제로는 UserData.stats에 upgradeLevels 같은 필드를 추가하는 것이 좋음.
    // 현재는 단순 구현을 위해 basePrice만 사용하거나, stats에 저장된 횟수를 참조함.
    
    int currentLevel = userData.stats.totalCleared ~/ 10; // 임시: 클리어 수에 비례한 가격 상승
    int price = item.getPrice(currentLevel);

    if (CurrencyService().gold >= price) {
      CurrencyService().spend(price, 0);
      item.onPurchase(userData);
      await CurrencyService().saveCurrentData(); // SyncManager.syncOnSave 호출 포함됨
      return true;
    }
    return false;
  }
}
