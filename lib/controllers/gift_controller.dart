import '../models/gift.dart';

class GiftController {
  final List<Gift> _gifts = [
    Gift(
      id: "1",
      eventId: "1", // Added eventId to link the gift to Event 1
      name: "Smartwatch",
      description: "A sleek and stylish smartwatch",
      category: "Electronics",
      price: 199.99,
    ),
    Gift(
      id: "2",
      eventId: "2", // Added eventId to link the gift to Event 2
      name: "Book: Flutter Essentials",
      description: "A comprehensive guide to Flutter development",
      category: "Books",
      price: 29.99,
    ),
  ];

  // Fetch all gifts for a specific event
  List<Gift> getGiftsForEvent(String eventId) {
    return _gifts.where((gift) => gift.eventId == eventId).toList();
  }

  // Fetch a sorted list of gifts for a specific event
  List<Gift> sortGiftsForEvent(String eventId, String criteria) {
    List<Gift> sortedGifts = getGiftsForEvent(eventId);
    if (criteria == "Name") {
      sortedGifts.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == "Category") {
      sortedGifts.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria == "Status") {
      sortedGifts.sort((a, b) => a.status.compareTo(b.status));
    }
    return sortedGifts;
  }

  // Add a gift to a specific event
  void addGift(Gift gift) {
    _gifts.add(gift);
  }

  // Delete a gift by its ID
  void deleteGift(String id) {
    _gifts.removeWhere((gift) => gift.id == id);
  }

  // Update an existing gift
  void updateGift(Gift updatedGift) {
    final index = _gifts.indexWhere((gift) => gift.id == updatedGift.id);
    if (index != -1) {
      _gifts[index] = updatedGift;
    }
  }

  // Pledge a gift by marking its status
  void pledgeGift(String id) {
    final index = _gifts.indexWhere((gift) => gift.id == id);
    if (index != -1) {
      _gifts[index].status = "Pledged";
    }
  }
}
