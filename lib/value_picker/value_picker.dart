import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forgix_framework/actions/action_result.dart';
import 'package:forgix_framework/nav/nav.dart';
import 'package:forgix_framework/responsive/responsive.dart';
import 'package:forgix_framework/utils/utils.dart';
import 'package:forgix_framework/widgets/conditional_widget.dart';

class ValuePicker<T> extends StatefulWidget {
  final T? value;
  final String? title;
  final String? description;
  final Future<ActionResult> Function(T? result)? onConfirm;
  final TextInputType? textInputType;

  const ValuePicker._({
    Key? key,
    this.value,
    this.onConfirm,
    this.title,
    this.description,
    this.textInputType,
  }) : super(key: key);

  static Future<int?> getInt(
    BuildContext context, {
    int? value,
    Future<ActionResult> Function(int? result)? onConfirm,
    String? title,
    String? description,
    TextInputType? textInputType,
  }) async {
    return await showDialog<int?>(
      context: context,
      builder: (context) {
        return ValuePicker<int?>._(
          value: value,
          onConfirm: onConfirm,
          textInputType: textInputType,
          title: title,
          description: description,
        );
      },
    );
  }

  static Future<double?> getDouble(
    BuildContext context, {
    double? value,
    Future<ActionResult> Function(double? result)? onConfirm,
    String? title,
    String? description,
    TextInputType? textInputType,
  }) async {
    return await showDialog<double?>(
      context: context,
      builder: (context) {
        return ValuePicker<double?>._(
          value: value,
          onConfirm: onConfirm,
          textInputType: textInputType,
          title: title,
          description: description,
        );
      },
    );
  }

  static Future<String?> getString(
    BuildContext context, {
    String? value,
    Future<ActionResult> Function(String? result)? onConfirm,
    String? title,
    String? description,
    TextInputType? textInputType,
  }) async {
    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return ValuePicker<String?>._(
          value: value,
          onConfirm: onConfirm,
          textInputType: textInputType,
          title: title,
          description: description,
        );
      },
    );
  }

  @override
  _ValuePickerState<T> createState() => _ValuePickerState<T>();
}

class _ValuePickerState<T> extends State<ValuePicker<T>> {
  T? value;
  String? errorMessage;
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  List<FilteringTextInputFormatter> formatters = [];

  @override
  void initState() {
    value = widget.value;

    if (isIntT<T>()) {
      if (value != null) {
        controller.text = formatNumberWithoutZeroes(value);
      }
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'(^\d*)')));
    } else if (isDoubleT<T>()) {
      if (value != null) {
        controller.text = formatNumberWithoutZeroes(value);
      }
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})')));
    } else {
      if (value != null) {
        controller.text = value.toString();
      }
    }

    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    super.initState();
  }

  T? generateResult(dynamic input) {
    if (isIntT<T>()) {
      return parseInt(input) as T?;
    } else if (isDoubleT<T>()) {
      return parseDouble(input) as T?;
    }

    return parseString(input) as T?;
  }

  void submit(result) async {
    if (widget.onConfirm != null) {
      ActionResult result = await widget.onConfirm!(value);

      if (result.fails) {
        FocusScope.of(context).requestFocus(focusNode);

        setState(() {
          errorMessage = result.message;
        });

        return;
      }
    }

    Nav.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Nav.pop(context, widget.value);
        return false;
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Responsive.sh(context, 40),
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(
                      widget.title ?? 'Ingrese un valor...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              ConditionalWidget(
                condition: widget.description != null,
                trueBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: 10,
                    ),
                    child: Text(
                      widget.description!,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: widget.textInputType,
                  controller: controller,
                  inputFormatters: formatters,
                  onChanged: (val) {
                    value = generateResult(val);
                  },
                  onFieldSubmitted: (result) async {
                    submit(result);
                  },
                  textAlign: TextAlign.center,
                ),
              ),
              ConditionalWidget(
                condition: errorMessage != null,
                trueChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    errorMessage ?? '',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TextButton(
                  onPressed: () {
                    submit(value);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
