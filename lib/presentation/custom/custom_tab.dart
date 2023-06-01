import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Tabs extends StatefulWidget {
  final TabController? tabController;
  final List<String> tabs;

  Tabs({required this.tabController, required this.tabs});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  @override
  void initState() {
    widget.tabController!.addListener(() {
      if (this.mounted) {
        setState(() {
          _currentIndex = widget.tabController!.index;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabList = widget.tabs
        .mapIndexed(
            (index, element) => tabItem(context, index: index, title: element))
        .toList();
    return TabBar(
      controller: widget.tabController,
      isScrollable: false,
      indicatorColor: Colors.transparent,
      labelColor: Colors.white,
      tabs: tabList,
    );
  }

  Widget tabItem(BuildContext context,
      {required int index, required String title}) {
    return Tab(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: _currentIndex == index
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
