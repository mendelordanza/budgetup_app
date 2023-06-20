import 'package:budgetup_app/helper/emoji_data_copy.dart';

List<EmojiData> emojis = [
  EmojiData("clothingAndAccessories", EmojiCopy.clothingAndAccessories),
  EmojiData("animalsNature", EmojiCopy.animalsNature),
  EmojiData("foodDrink", EmojiCopy.foodDrink),
  EmojiData("activityAndSports", EmojiCopy.activityAndSports),
  EmojiData("travelPlaces", EmojiCopy.travelPlaces),
  EmojiData("objects", EmojiCopy.objects),
  EmojiData("flags", EmojiCopy.flags),
];

class EmojiData {
  String category;
  List<String> emojiIcons;

  EmojiData(this.category, this.emojiIcons);
}
