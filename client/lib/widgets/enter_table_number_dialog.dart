import 'package:flutter/material.dart';

class EnterTableNumberDialog extends StatefulWidget {
  const EnterTableNumberDialog({
    Key? key,
    this.isCheckout = false,
  }) : super(key: key);
  final bool isCheckout;
  @override
  State<EnterTableNumberDialog> createState() => _EnterTableNumberDialogState();
}

class _EnterTableNumberDialogState extends State<EnterTableNumberDialog> {
  final _tableNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Table Number'),
      content: TextField(
        decoration: const InputDecoration(labelText: 'Table Number'),
        keyboardType: TextInputType.text,
        controller: _tableNumberController,
      ),
      actions: <Widget>[
        if (!widget.isCheckout)
          TextButton(
            child: const Text('In Queue'),
            onPressed: () {
              Navigator.of(context).pop("");
            },
          ),
        TextButton(
          onPressed: () {
            if (_tableNumberController.text.isEmpty) {
              return;
            }
            Navigator.of(context).pop(_tableNumberController.text);
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
