import 'package:flutter/material.dart';
import 'package:lyra_framework/nav/nav.dart';
import 'package:lyra_framework/responsive/responsive.dart';
import 'package:lyra_framework/widgets/conditional_widget.dart';

enum DialogType {
  success,
  warning,
  danger,
  info,
  loading,
}

abstract class DialogManager {
  static void hide(BuildContext context) async {
    Nav.pop(context);
  }

  static void loading(
    BuildContext context, {
    String? description,
  }) {
    _show(
      context,
      _VolkerixDialogData(
        dialogType: DialogType.loading,
        title: '',
        acceptText: 'Accept',
        cancelText: 'Cancel',
        description: description ?? 'Processing...',
      ),
    );
  }

  static void show(
    BuildContext context, {
    required DialogType dialogType,
    required String title,
    required String description,
    void Function()? onDismiss,
    String? acceptText,
    String? cancelText,
    void Function()? onCancel,
    void Function()? onAccept,
  }) {
    _show(
      context,
      _VolkerixDialogData(
        dialogType: dialogType,
        title: title,
        description: description,
        onDismiss: onDismiss,
        acceptText: acceptText ?? 'Accept',
        cancelText: cancelText ?? 'Cancel',
        onAccept: onAccept,
        onCancel: onCancel,
      ),
    );
  }

  static void _show(BuildContext context, _VolkerixDialogData data) {
    final _VolkerixDialogState? state = _VolkerixDialogState.currentState;

    if (state != null) {
      state.setData(data);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return _VolkerixDialog(
          data: data,
        );
      },
    );
  }
}

class _VolkerixDialogData {
  final DialogType dialogType;
  final String title;
  final String description;
  final void Function()? onDismiss;
  final String acceptText;
  final String cancelText;
  final void Function()? onCancel;
  final void Function()? onAccept;

  const _VolkerixDialogData({
    required this.dialogType,
    required this.title,
    required this.description,
    required this.acceptText,
    required this.cancelText,
    this.onDismiss,
    this.onCancel,
    this.onAccept,
  });
}

class _VolkerixDialog extends StatefulWidget {
  final _VolkerixDialogData data;

  const _VolkerixDialog({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _VolkerixDialogState createState() => _VolkerixDialogState();
}

class _VolkerixDialogState extends State<_VolkerixDialog> {
  late _VolkerixDialogData data;
  static _VolkerixDialogState? currentState;

  void setData(_VolkerixDialogData data) {
    setState(() {
      this.data = data;
    });
  }

  @override
  void dispose() {
    super.dispose();

    currentState = null;
  }

  @override
  void initState() {
    super.initState();

    currentState = this;
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    late final Color backgroundColor;

    if (data.dialogType == DialogType.danger) {
      backgroundColor = Responsive.value(
        context,
        mobile: Colors.red[100]!,
        desktop: Colors.red,
      );
    } else if (data.dialogType == DialogType.info) {
      backgroundColor = Responsive.value(
        context,
        mobile: Colors.blue[100]!,
        desktop: Colors.blue,
      );
    } else if (data.dialogType == DialogType.success) {
      backgroundColor = Responsive.value(
        context,
        mobile: Colors.green[100]!,
        desktop: Colors.green,
      );
    } else if (data.dialogType == DialogType.warning) {
      backgroundColor = Responsive.value(
        context,
        mobile: Colors.yellow[100]!,
        desktop: Colors.yellow.shade700,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final bool canDismiss = data.onDismiss != null;

        data.onDismiss?.call();

        return canDismiss;
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Responsive.sh(context, 40),
            maxWidth: 400,
            minWidth: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConditionalWidget(
              condition: data.dialogType == DialogType.loading,
              trueBuilder: (context) {
                return Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    Text(
                      data.description,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
              falseBuilder: (context) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Responsive(
                        mobile: const SizedBox(),
                        tablet: Container(
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: backgroundColor,
                          ),
                          child: icon,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: Responsive.value(
                            context,
                            mobile: CrossAxisAlignment.center,
                            tablet: CrossAxisAlignment.start,
                          ),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Responsive(
                              mobile: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: backgroundColor,
                                ),
                                child: icon,
                              ),
                              tablet: const SizedBox(),
                              desktop: const SizedBox(),
                            ),
                            SizedBox(
                              height: Responsive.value(context, mobile: 15, tablet: 0),
                            ),
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: Responsive.value(context, mobile: 16, tablet: 14),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data.description,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _ActionButtons(state: this),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget get icon {
    late final IconData _icon;
    late final Color _color;
    if (data.dialogType == DialogType.danger) {
      _icon = Icons.error_outline;
      _color = Responsive.value(
        context,
        mobile: Colors.red,
        desktop: Colors.white,
      );
    } else if (data.dialogType == DialogType.info) {
      _icon = Icons.announcement_outlined;
      _color = Responsive.value(
        context,
        mobile: Colors.blue,
        desktop: Colors.white,
      );
    } else if (data.dialogType == DialogType.success) {
      _icon = Icons.check;
      _color = Responsive.value(
        context,
        mobile: Colors.green,
        desktop: Colors.white,
      );
    } else if (data.dialogType == DialogType.warning) {
      _icon = Icons.error_outline;
      _color = Responsive.value(
        context,
        mobile: Colors.yellow.shade700,
        desktop: Colors.white,
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Icon(
        _icon,
        color: _color,
        size: 30,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final _VolkerixDialogState state;

  const _ActionButtons({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
      condition: state.data.onAccept != null || state.data.onCancel != null,
      trueBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConditionalWidget(
                condition: state.data.onCancel != null,
                trueChild: Expanded(
                  child: TextButton(
                    onPressed: () {
                      state.data.onCancel?.call();
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    child: Text(
                      state.data.cancelText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              ConditionalWidget(
                condition: state.data.onAccept != null && state.data.onCancel != null,
                trueChild: const SizedBox(width: 10),
              ),
              ConditionalWidget(
                condition: state.data.onAccept != null,
                trueChild: Expanded(
                  child: TextButton(
                    onPressed: () {
                      state.data.onAccept?.call();
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: Text(
                      state.data.acceptText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
