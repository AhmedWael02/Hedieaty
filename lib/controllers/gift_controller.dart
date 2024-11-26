import '../models/gift.dart';
import 'database_helper.dart';

class GiftController {
  final DatabaseHelper _dbHelper = DatabaseHelper();



  Future<List<Gift>> getGiftsByEventId(String eventId) async {
    final gifts = await _dbHelper.getGiftsByEventId(eventId);
    return gifts.map((giftMap) {
      return Gift(
        id: giftMap['id'],
        eventId: giftMap['eventId'],
        name: giftMap['name'],
        description: giftMap['description'],
        category: giftMap['category'],
        price: giftMap['price'],
        status: giftMap['status'],
        pledgedBy: giftMap['pledgedByUserId'],
      );
    }).toList();
  }

  Future<List<Gift>> sortGiftsForEvent(String eventId, String criteria) async {
    // Fetch events for the given user ID
    List<Gift> gifts = await getGiftsByEventId(eventId);

    // Sort the gifts based on the criteria
    if (criteria == "Name") {
      gifts.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == "Category") {
      gifts.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria == "Status") {
      gifts.sort((a, b) => a.status.compareTo(b.status));
    }

    return gifts;
  }


  // Fetch all pledged gifts for a specific user
  Future<List<Gift>> getPledgedGifts(String userId) async {
    // Fetch all gifts from the database
    final db = await _dbHelper.database;
    final giftMaps = await db.query('Gifts');

    // Map the database rows to Gift objects
    List<Gift> gifts = giftMaps.map((giftMap) {
      return Gift(
        id: giftMap['id'] as String,
        eventId: giftMap['eventId'] as String,
        name: giftMap['name'] as String,
        description: giftMap['description'] as String,
        category: giftMap['category'] as String,
        price: giftMap['price'] as double,
        status: giftMap['status'] as String,
        pledgedBy: giftMap['pledgedByUserId'] as String?,
      );
    }).toList();

    // Filter the gifts based on the pledgedByUserId field
    return gifts.where((gift) => gift.pledgedBy == userId).toList();
  }



  // Add a gift to a specific event
  Future<void> addGift(Gift gift) async {
    await _dbHelper.insertGift({
      'id': gift.id,
      'eventId': gift.eventId,
      'name': gift.name,
      'description': gift.description,
      'category': gift.category,
      'price': gift.price,
      'status': gift.status,
      'pledgedByUserId': gift.pledgedBy,
    });
  }

  Future<void> deleteGift(String id) async {
    final db = await _dbHelper.database;
    await db.delete('Gifts', where: 'id = ?', whereArgs: [id]);
  }



  Future<void> updateGift(Gift gift) async {
    final db = await _dbHelper.database;
    await db.update(
      'Gifts',
      {
        'eventId': gift.eventId,
        'name': gift.name,
        'description': gift.description,
        'category': gift.category,
        'price': gift.price,
        'status': gift.status,
        'pledgedByUserId': gift.pledgedBy,
      },
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  // Pledge a gift by marking its status and pledgedBy field
  Future<void> pledgeGift(String giftId, String userId) async {
    final db = await _dbHelper.database;
    await db.update(
      'Gifts',
      {'status': 'Pledged', 'pledgedByUserId': userId},
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

}



