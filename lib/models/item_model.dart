// lib/models/item_model.dart

enum ItemType { potion, mana, equipment, misc }

class Item {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final int value; // HP 회복량, 공격력 가산치 등
  int count;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.count = 1,
  });

  Item clone() {
    return Item(
      id: id,
      name: name,
      description: description,
      type: type,
      value: value,
      count: count,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      value: json['value'],
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'count': count,
    };
  }
}

class ItemTemplates {
  static Item healthPotion() => Item(
    id: 'hp_potion',
    name: '체력 포션',
    description: '사용 시 HP를 30 회복합니다.',
    type: ItemType.potion,
    value: 30,
  );

  static Item attackBuff() => Item(
    id: 'atk_buff',
    name: '공격력 영약',
    description: '사용 시 공격력을 영구적으로 5 증가시킵니다.',
    type: ItemType.misc,
    value: 5,
  );
}
