import 'package:emoji_data/emoji_data.dart';

List<EmojiData> emojis = [
  EmojiData("smileys", Emoji.smileys),
  EmojiData("gesturesAndBodyParts", Emoji.gesturesAndBodyParts),
  EmojiData("peopleAndFantasy", Emoji.peopleAndFantasy),
  EmojiData("clothingAndAccessories", Emoji.clothingAndAccessories),
  EmojiData("paleEmojis", Emoji.paleEmojis),
  EmojiData("creamWhiteEmojis", Emoji.creamWhiteEmojis),
  EmojiData("brownEmojis", Emoji.brownEmojis),
  EmojiData("blackEmojis", Emoji.blackEmojis),
  EmojiData("animalsNature", Emoji.animalsNature),
  EmojiData("foodDrink", Emoji.foodDrink),
  EmojiData("activityAndSports", Emoji.activityAndSports),
  EmojiData("travelPlaces", Emoji.travelPlaces),
  EmojiData("objects", Emoji.objects),
  EmojiData("symbols", Emoji.symbols),
  EmojiData("flags", Emoji.flags),
];

class EmojiData {
  String category;
  List<String> emojiIcons;

  EmojiData(this.category, this.emojiIcons);
}
