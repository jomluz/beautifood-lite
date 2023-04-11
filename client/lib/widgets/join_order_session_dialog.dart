
import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/utils/validators.dart';
import 'package:beautifood_lite/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinOrderSessionDialog extends StatefulWidget {
  const JoinOrderSessionDialog({
    Key? key,
    required this.shopId,
  }) : super(key: key);
  final String shopId;
  @override
  State<JoinOrderSessionDialog> createState() => _JoinOrderSessionDialogState();
}

class _JoinOrderSessionDialogState extends State<JoinOrderSessionDialog> {
  bool _isLoading = false;
  String? _sessionId;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Shop>(context, listen: false)
          .newOrder(null, _sessionId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      showErrorDialog(error.toString(), context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Order Session'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Order Session ID'),
          keyboardType: TextInputType.text,
          validator: Validator.validateRequired,
          onSaved: (value) {
            _sessionId = value;
          },
        ),
      ),
      actions: <Widget>[
        if (!_isLoading)
          TextButton(
            child: const Text('View Menu'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        _isLoading
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: _submit,
                child: const Text('OK'),
              ),
      ],
    );
  }
}
