import 'package:flutter/material.dart';
import 'package:git7assignment/enum/fibo_type.dart';
import 'package:git7assignment/models/fibo_model.dart';
import 'fibo_logic_mixin.dart';

class FiboHome extends StatefulWidget {
  const FiboHome({super.key});
  @override
  State<FiboHome> createState() => _FiboHomeState();
}

class _FiboHomeState extends State<FiboHome> with FiboLogicMixin {
  late List<FiboItem> mainList;
  final List<FiboItem> bottomList = [];
  late ScrollController _scroll;

  FiboItem? lastAddedItem;
  int? lastRestoredIndex;
  FiboType? lastTappedType;

  final Map<int, GlobalKey> itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    final fibs = generateFib(40);
    mainList = List.generate(fibs.length, (i) => FiboItem(fibs[i], i));
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

  void _onBottomTap(FiboItem item) {
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
