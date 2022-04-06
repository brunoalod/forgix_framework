import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:forgix_framework/nav/nav.dart';
import 'package:forgix_framework/responsive/responsive.dart';
import 'package:forgix_framework/widgets/conditional_widget.dart';

enum ListPickerMode { single, multi }

class ListPicker<T> extends StatefulWidget {
  final List<ListPickerOption> options;
  final List<T> selected;
  final void Function(List<T> result)? onSave;
  final void Function()? onCancel;
  final ListPickerMode mode;

  static Future<T?> single<T>(
    BuildContext context, {
    required List<ListPickerOption> options,
    void Function(T? result)? onSave,
    void Function()? onCancel,
    T? selected,
  }) async {
    List<T> _selected = [];

    if (selected != null) {
      _selected.add(selected);
    }

    T? result = await showDialog<T?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ListPicker<T>(
          options: options,
          onSave: (list) {
            if (onSave == null) return;

            if (list.isNotEmpty) {
              onSave(list.first);
              return;
            }

            onSave(null);
          },
          onCancel: onCancel,
          selected: _selected,
          mode: ListPickerMode.single,
        );
      },
    );

    return result;
  }

  static Future<List<T>> multiple<T>(
    BuildContext context, {
    required List<ListPickerOption> options,
    void Function(List<T> result)? onSave,
    void Function()? onCancel,
    List<T> selected = const [],
  }) async {
    List<T>? result = await showDialog<List<T>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ListPicker<T>(
          options: options,
          onSave: onSave,
          onCancel: onCancel,
          selected: selected,
          mode: ListPickerMode.multi,
        );
      },
    );

    return result ?? [];
  }

  const ListPicker({
    Key? key,
    required this.options,
    required this.onSave,
    this.onCancel,
    this.selected = const [],
    required this.mode,
  }) : super(key: key);

  @override
  _ListPickerState<T> createState() => _ListPickerState<T>();
}

class _ListPickerState<T> extends State<ListPicker<T>> {
  List<T> selected = [];
  List<T> original = [];

  @override
  void initState() {
    selected = List<T>.from(widget.selected);
    original = List<T>.from(selected);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.mode == ListPickerMode.multi) {
          Nav.pop(context, original);
        } else {
          if (original.isNotEmpty) {
            Nav.pop(context, original.first);
          } else {
            Nav.pop(context, null);
          }
        }

        return false;
      },
      child: Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Responsive.sh(context, 40),
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Seleccione una opción...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    ListPickerOption option = widget.options[index];
                    return _ListPickerTile(
                      option: option,
                      isSelected: selected.contains(option.value),
                      mode: widget.mode,
                      onChanged: () {
                        setState(() {
                          if (widget.mode == ListPickerMode.multi) {
                            if (selected.contains(option.value)) {
                              selected.remove(option.value);
                            } else {
                              selected.add(option.value);
                            }
                          } else {
                            selected = [option.value];
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        onSurface: Colors.red,
                        primary: Colors.red,
                      ),
                      child: const Text(
                        'BORRAR',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        primary: Colors.black,
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onSave();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        primary: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDelete() {
    setState(() {
      selected = [];
    });
  }

  void onCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }

    if (widget.mode == ListPickerMode.multi) {
      Nav.pop(context, original);
    } else {
      if (original.isNotEmpty) {
        Nav.pop(context, original.first);
      } else {
        Nav.pop(context, null);
      }
    }
  }

  void onSave() {
    List<T> result = [];

    for (var item in selected) {
      result.add(item);
    }

    if (widget.onSave != null) {
      widget.onSave!(result);
    }

    if (widget.mode == ListPickerMode.multi) {
      Nav.pop(context, selected);
    } else {
      if (selected.isNotEmpty) {
        Nav.pop(context, selected.first);
      } else {
        Nav.pop(context, null);
      }
    }
  }
}

class _ListPickerTile extends StatefulWidget {
  final ListPickerOption option;
  final Function()? onChanged;
  final bool isSelected;
  final ListPickerMode mode;

  const _ListPickerTile({
    Key? key,
    required this.option,
    required this.onChanged,
    required this.isSelected,
    required this.mode,
  }) : super(key: key);

  @override
  __ListPickerTileState createState() => __ListPickerTileState();
}

class __ListPickerTileState extends State<_ListPickerTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          children: [
            Expanded(child: Text(widget.option.text)),
            ConditionalWidget(
              condition: widget.mode == ListPickerMode.multi,
              trueChild: Checkbox(
                value: widget.isSelected,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (_) {
                  Feedback.forTap(context);

                  if (widget.onChanged != null) {
                    widget.onChanged!();
                  }
                },
              ),
              falseChild: Checkbox(
                value: widget.isSelected,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99999),
                ),
                onChanged: (_) {
                  Feedback.forTap(context);
                  if (widget.onChanged != null) {
                    widget.onChanged!();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListPickerOption {
  final dynamic value;
  final String text;

  ListPickerOption({
    required this.value,
    required this.text,
  });
}

class ListPickerTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onPressed;

  const ListPickerTile({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      minVerticalPadding: 0,
      visualDensity: VisualDensity.standard,
      dense: true,
      trailing: SizedBox(
        width: Responsive.sw(context, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConditionalWidget(
              condition: isSelected,
              trueChild: Icon(
                FeatherIcons.check,
                color: Theme.of(context).primaryColor,
              ),
              falseChild: const Icon(FeatherIcons.chevronRight),
            ),
          ],
        ),
      ),
      onTap: () async {
        bool canDelay = await canTapDelay();

        if (!canDelay) {
          return;
        }

        onPressed();
      },
    );
  }
}
