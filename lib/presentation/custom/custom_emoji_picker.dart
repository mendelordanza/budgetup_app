import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/emoji_icons.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomEmojiPicker extends HookWidget {
  const CustomEmojiPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: emojis.length);
    final _selectedEmoji = useState<String>("");

    return Container(
      padding: EdgeInsets.all(
        16.0,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: tabController,
            tabs: emojis
                .map(
                  (e) => Tab(
                    icon: Text(
                      e.emojiIcons[0],
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                )
                .toList(),
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: emojis.map((e) {
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: e.emojiIcons.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _selectedEmoji.value = e.emojiIcons[index];
                      },
                      child: Container(
                        decoration: _selectedEmoji.value == e.emojiIcons[index]
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: secondaryColor.withOpacity(0.5),
                              )
                            : null,
                        child: Center(
                            child: Text(
                          e.emojiIcons[index],
                          style: TextStyle(
                            fontSize: 30.0,
                          ),
                        )),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          if (_selectedEmoji.value.isNotEmpty)
            CustomButton(
                onPressed: () {
                  Navigator.pop(context, _selectedEmoji.value);
                },
                child: Text("Select"))
        ],
      ),
    );
  }
}
