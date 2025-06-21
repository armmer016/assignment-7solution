import 'package:flutter/material.dart';

enum FiboType { circle, cross, square }

class _FiboItem {
  final int value;
  final int originalIndex;
  _FiboItem(this.value, this.originalIndex);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(home: const FiboHome());
}

FiboType getType(int n) {
  switch (n % 3) {
    case 0:
      return FiboType.circle;
    case 1:
      return FiboType.cross;
    default:
      return FiboType.square;
  }
}

IconData iconFor(FiboType t) {
  switch (t) {
    case FiboType.cross:
      return Icons.close;
    case FiboType.square:
      return Icons.crop_square;
    case FiboType.circle:
      return Icons.circle_outlined;
  }
}

List<int> generateFib(int count) {
  final list = <int>[0, 1];
  while (list.length < count) {
    list.add(list[list.length - 1] + list[list.length - 2]);
  }
  return list.take(count).toList();
}

class FiboHome extends StatefulWidget {
  const FiboHome({super.key});
  @override
  State<FiboHome> createState() => _FiboHomeState();
}

class _FiboHomeState extends State<FiboHome> {
  late List<_FiboItem> mainList;
  final List<_FiboItem> bottomList = [];
  late ScrollController _scroll;

  _FiboItem? lastAddedItem;
  int? lastRestoredIndex;
  FiboType? lastTappedType;

  final Map<int, GlobalKey> itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    final fibs = generateFib(40);
    mainList = List.generate(fibs.length, (i) => _FiboItem(fibs[i], i));
  }

  void _onMainTap(int index, int n) {
    setState(() {
      final item = mainList.removeAt(index);
      bottomList.add(item);
      lastAddedItem = item;
      lastTappedType = getType(item.value);
      lastRestoredIndex = null;
    });
    showModalBottomSheet(context: context, builder: (_) => _buildBottomSheet());
  }

  Widget _buildBottomSheet() {
    final type = lastTappedType!;
    final items = bottomList
        .where((entry) => getType(entry.value) == type)
        .toList();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final entry = items[i];
        final n = entry.value;
        return InkWell(
          onTap: () => _onBottomTap(entry),
          child: Container(
            color: entry == lastAddedItem ? Colors.greenAccent : null,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Text('Idx: ${entry.originalIndex}, Num: $n'),
                const Spacer(),
                Icon(iconFor(type)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBottomTap(_FiboItem item) {
    setState(() {
      bottomList.remove(item);
      final indexToInsert = mainList.indexWhere(
        (i) => i.originalIndex >= item.originalIndex,
      );
      mainList.insert(
        indexToInsert == -1 ? mainList.length : indexToInsert,
        item,
      );
      lastRestoredIndex = item.originalIndex;
      lastAddedItem = null;
    });
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lastRestoredIndex != null) {
        final ctx = itemKeys[lastRestoredIndex!]!.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fibonacci List')),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: mainList.map((entry) {
            final i = entry.originalIndex;
            final n = entry.value;
            final type = getType(n);
            final itemKey = itemKeys[i] ??= GlobalKey();
            return InkWell(
              onTap: () => _onMainTap(mainList.indexOf(entry), n),
              child: Container(
                key: itemKey,
                color: entry.originalIndex == lastRestoredIndex
                    ? Colors.redAccent
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Text('Index: ${entry.originalIndex}, Number: $n'),
                    const Spacer(),
                    Icon(iconFor(type)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
