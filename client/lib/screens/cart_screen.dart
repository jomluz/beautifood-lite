import 'package:auto_size_text/auto_size_text.dart';
import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/theme/colors.dart';
import 'package:beautifood_lite/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CartPath extends AppRoutePath {
  @override
  String getRouteInformation() {
    return '/cart';
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  // final VoidCallback goToOrderHistory;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String>? _selectedOrderItems;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<Shop>(
        builder: (context, shop, child) {
          if (shop.orderSessionId == null) {
            return Center(
                child: SizedBox(
              width: deviceSize.aspectRatio > 1
                  ? deviceSize.width * 0.6
                  : deviceSize.width * 0.9,
              child: const Text('You are not in an order session!'),
            ));
          }
          if (shop.currentOrder != null && _selectedOrderItems == null) {
            _selectedOrderItems = shop.currentOrder!.orderItems
                .where((element) => element.confirmedTime == null)
                .map((e) => e.id)
                .toList();
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: deviceSize.aspectRatio > 1
                          ? deviceSize.width * 0.6
                          : deviceSize.width * 0.9,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'Order Session: ${shop.orderSessionId}'),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: shop.orderSessionId??""));
                                },
                                icon: const Icon(Icons.copy),
                              ),
                              IconButton(
                                onPressed: () {
                                  Share.share(
                                      'Join My Order Session on Beautifood! https://app.beautifood.io/#/shop/${Provider.of<Shop>(context).selectedShopId}?sessionId=${shop.orderSessionId} \n Session ID: ${shop.orderSessionId}',
                                      subject:
                                          'Join Beautifood Order Session!');
                                },
                                icon: const Icon(Icons.share),
                              ),
                            ],
                          ),
                          shop.currentOrder?.orderItems.isEmpty??true
                              ? const Text('Nothing in order, add something...')
                              : Text(
                                  'Table Number: ${shop.currentOrder!.tableNumber}'),
                          if (shop.currentOrder != null)
                            ...shop.currentOrder!.orderItems.map(
                              (e) => InkWell(
                                onTap: () {
                                  if (e.confirmedTime != null) return;
                                  if (_selectedOrderItems!.contains(e.id)) {
                                    setState(() {
                                      _selectedOrderItems!.removeWhere(
                                          (element) => element == e.id);
                                    });
                                  } else {
                                    setState(() {
                                      _selectedOrderItems!.add(e.id);
                                    });
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color:
                                            _selectedOrderItems!.contains(e.id)
                                                ? ThemeColors.primarySwatch
                                                : Colors.transparent),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8.0,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AutoSizeText(
                                                  e.name,
                                                  maxLines: 2,
                                                  minFontSize: 8,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: AutoSizeText(
                                                "x ${e.quantity.toString()}",
                                                minFontSize: 8,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: AutoSizeText(
                                                '${Provider.of<Shop>(context).shopData!.currency.symbol} ${e.subtotal.toStringAsFixed(2)}',
                                                minFontSize: 8,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  shop.removeItemFromOrderSession(e.id);
                                                },
                                                icon: const Icon(Icons.delete))
                                          ],
                                        ),
                                        if (e.confirmedTime != null)
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Submitted'),
                                          ),
                                        ...e.otherAttributes.map(
                                          (attribute) => Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 16.0),
                                                child: Text(attribute.key),
                                              ),
                                              Expanded(child: Container()),
                                            ],
                                          ),
                                        ),
                                        if (e.remarks != "")
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 16.0),
                                            child: Text(
                                              "Remarks: ${e.remarks}",
                                              style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_selectedOrderItems!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(builder: (context) {
                        double total = shop.currentOrder!.orderItems
                                .where((element) =>
                                    _selectedOrderItems!.contains(element.id))
                                .map((e) => e.subtotal)
                                .reduce((value, element) => value + element);
                        // final taxRate = Provider.of<Shop>(context)
                        //     .shopData!
                        //     .taxRates
                        //     .map((e) => e.rate)
                        //     .reduce((value, element) => value + element);
                        // total *= (1 + taxRate);
                        return AutoSizeText(
                          'Total: ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        );
                      }),
                    ),
                    // if (orders.currentOrder?.userId ==
                    //     Provider.of<GraphQLService>(context, listen: false)
                    //         .userId)
                    _isLoading
                        ? const CircularProgressIndicator()
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ThemeColors.primarySwatch,
                              side: const BorderSide(
                                width: 2.0,
                                color: ThemeColors.primarySwatch,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                final res = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                        'Submit ${_selectedOrderItems!.length} Order Items'),
                                    content: const Text(
                                        'Order Items cannot be modified once submitted!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  ),
                                );
                                if (res == true) {
                                  await shop
                                      .submitOrderItems(_selectedOrderItems!);
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              } catch (error) {
                                showErrorDialog(error.toString(), context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Submit ${_selectedOrderItems!.length} items',
                                style: const TextStyle(
                                  color: ThemeColors.primarySwatch,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
