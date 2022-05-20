import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lyra_framework/widgets/conditional_widget.dart';

class BottomSheetItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final dynamic value;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool? bordered;
  final bool? enabled;

  BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
    this.primaryColor = Colors.black,
    this.backgroundColor,
    this.bordered = false,
    this.enabled = true,
  });
}

class BottomSheetSelector extends StatefulWidget {
  final List<BottomSheetItem> items;
  final Function(BottomSheetItem)? onSelected;
  final ScrollController scrollbarController = ScrollController();

  BottomSheetSelector({
    Key? key,
    required this.items,
    this.onSelected,
  }) : super(key: key);

  static void show<T>(
    BuildContext context, {
    List<BottomSheetItem>? items,
    int? itemCount,
    Function(BuildContext context, int index)? itemBuilder,
    Function(BottomSheetItem)? onSelected,
  }) {
    assert(items == null ? itemCount != null && itemBuilder != null : true);

    if (items == null) {
      items = [];
      for (var i = 0; i < itemCount!; i++) {
        items.add(itemBuilder!(context, i));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (BuildContext context) {
        return BottomSheetSelector(
          items: items!,
          onSelected: onSelected,
        );
      },
    );
  }

  @override
  _BottomSheetSelectorState createState() => _BottomSheetSelectorState();
}

class _BottomSheetSelectorState extends State<BottomSheetSelector> {
  final TextEditingController _textController = TextEditingController();
  List<BottomSheetItem> items = [];
  List<BottomSheetItem> newItems = [];
  String inputValue = "";

  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    items = widget.items;
    super.initState();
  }

  onItemChanged(String value) {
    inputValue = value;
    newItems = items
        .where((element) => element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();

    if (value == "") {
      newItems.clear();
    }

    setState(() {});
    return newItems;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 0.15,
                height: 5,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              SizedBox(
                height: 300,
                child: ConditionalWidget(
                  condition: (inputValue != "" ? newItems.length : items.length) > 0,
                  trueChild: CupertinoScrollbar(
                    controller: widget.scrollbarController,
                    thumbVisibility: true,
                    thickness: 4,
                    child: ListView.builder(
                      controller: widget.scrollbarController,
                      itemCount: inputValue != "" ? newItems.length : items.length,
                      itemBuilder: (context, index) {
                        BottomSheetItem item = inputValue != "" ? newItems[index] : items[index];

                        final bool ultimo =
                            index + 1 == (inputValue != "" ? newItems.length : items.length);

                        return Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            left: 20,
                            right: 20,
                            bottom: ultimo ? 20 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: item.enabled == true ? Colors.transparent : Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                            border: item.bordered == true
                                ? Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  )
                                : null,
                          ),
                          height: 80,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  ConditionalWidget(
                                    condition: item.icon != null,
                                    trueBuilder: (context) {
                                      return SizedBox(
                                        width: 40,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    item.backgroundColor ?? Colors.grey[200],
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Icon(
                                                item.icon,
                                                size: 30,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  ConditionalWidget(
                                    condition: item.icon != null,
                                    trueChild: const SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            color: item.primaryColor,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        ConditionalWidget(
                                          condition: item.subtitle != null,
                                          trueBuilder: (context) {
                                            return Text(
                                              item.subtitle!,
                                              style: TextStyle(
                                                color: item.primaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: item.enabled == true
                                ? () {
                                    if (widget.onSelected != null) {
                                      widget.onSelected!(item);
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  falseChild: const Text('Esta opción no está disponible.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
