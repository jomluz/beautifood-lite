import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/theme/colors.dart';
import 'package:beautifood_lite/widgets/enter_table_number_dialog.dart';
import 'package:beautifood_lite/widgets/error_dialog.dart';
import 'package:beautifood_lite/widgets/join_order_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderSessionDialog extends StatelessWidget {
  const OrderSessionDialog({
    Key? key,
    required this.shopId,
  }) : super(key: key);
  final String shopId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Order Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final res = await showDialog(
                  context: context,
                  builder: (ctx) => JoinOrderSessionDialog(shopId: shopId));
              if (res == true) {
                navigator.pop(true);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.primarySwatch,
              side: const BorderSide(
                width: 2.0,
                color: ThemeColors.primarySwatch,
              ),
              shape: const StadiumBorder(),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Join Order Session',
                style: TextStyle(
                  color: ThemeColors.primarySwatch,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'or',
              style: TextStyle(
                color: ThemeColors.primarySwatch,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              try {
                final shop = Provider.of<Shop>(context, listen: false);
                final res = await showDialog(
                    context: context,
                    builder: (ctx) => const EnterTableNumberDialog());
                if (res == null) return;
                await shop.newOrder(res, null);
                navigator.pop(true);
              } catch (error) {
                showErrorDialog(error.toString(), context);
              }
              final res = await showDialog(
                  context: context,
                  builder: (ctx) => JoinOrderSessionDialog(shopId: shopId));
              if (res == true) {
                navigator.pop(true);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.primarySwatch,
              side: const BorderSide(
                width: 2.0,
                color: ThemeColors.primarySwatch,
              ),
              shape: const StadiumBorder(),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Create Order Session',
                style: TextStyle(
                  color: ThemeColors.primarySwatch,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
