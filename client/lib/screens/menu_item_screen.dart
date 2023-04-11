import 'dart:math';

import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/widgets/enter_table_number_dialog.dart';
import 'package:beautifood_lite/widgets/error_dialog.dart';
import 'package:beautifood_lite/widgets/order_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuItemPath extends AppRoutePath {
  final String shopId;
  final String menuItemId;
  MenuItemPath(this.shopId, this.menuItemId);
  @override
  String getRouteInformation() {
    return '/shop/$shopId/$menuItemId';
  }
}

class MenuItemScreen extends StatefulWidget {
  const MenuItemScreen(
      {Key? key,
      required this.shopId,
      required this.menuItemId,
      required this.goBackToMenu})
      : super(key: key);
  final String shopId;
  final String menuItemId;
  final VoidCallback goBackToMenu;

  @override
  State<MenuItemScreen> createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  MenuItem? _menuItem;
  final Map<String, String> _optionsMap = {};
  final List<OrderItemAttribute> _orderItemAttributes = [];
  String _remarks = "";
  final _quantityController = TextEditingController(text: "1");
  bool _isDineIn = true;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Consumer<Shop>(builder: (context, shop, _) {
      return Scaffold(
        appBar: shop.getMenuItem(widget.menuItemId) == null
            ? AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0.0,
                title: const Text(
                  'Menu Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: FutureBuilder(
            future: shop.shopData == null ? shop.getShop() : null,
            builder: (context, snapshot) {
              _menuItem = shop.getMenuItem(widget.menuItemId);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (_menuItem == null) {
                return const Center(
                  child: Text('Menu Item not Found'),
                );
              }
              if (Provider.of<Shop>(context).orderSessionId == null) {
                Future.delayed(
                    Duration.zero,
                    () => showDialog(
                          context: context,
                          builder: (ctx) =>
                              OrderSessionDialog(shopId: shop.selectedShopId!),
                        ));
              }
              return Center(
                child: SizedBox(
                  width: deviceSize.aspectRatio > 1
                      ? deviceSize.width * 0.6
                      : deviceSize.width * 0.9,
                  child: CustomScrollView(slivers: [
                    SliverAppBar(
                      title: Text(_menuItem!.title),
                      expandedHeight: _menuItem!.imageUrls.isEmpty
                          ? null
                          : deviceSize.aspectRatio > 1
                              ? deviceSize.width * 0.6 / 16 * 9
                              : deviceSize.width * 0.6 / 16 * 9,
                      flexibleSpace: _menuItem!.imageUrls.isEmpty
                          ? null
                          : FlexibleSpaceBar(
                              background: Image.network(
                                _menuItem!.imageUrls[0],
                                height: deviceSize.aspectRatio > 1
                                    ? deviceSize.width * 0.6 / 16 * 9
                                    : deviceSize.width * 0.6 / 16 * 9,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 30.0,
                        maxHeight: 30.0,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_menuItem!.description),
                        ),
                      ]),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 30.0,
                        maxHeight: 30.0,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Text(
                              'Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ..._menuItem!.options
                        .map(
                          (e) => [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _SliverAppBarDelegate(
                                minHeight: 30.0,
                                maxHeight: 30.0,
                                child: Container(
                                  color: const Color(0xfff5f5f5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  ...e.choices.map(
                                    (choice) => RadioListTile<String>(
                                      title: Text(choice.key),
                                      subtitle: Text(choice.priceAmendment
                                          .toStringAsFixed(2)),
                                      groupValue: _optionsMap[e.name],
                                      value: choice.key,
                                      dense: true,
                                      onChanged: (value) {
                                        setState(() {
                                          _optionsMap[e.name] = choice.key;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        .expand((element) => element),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 30.0,
                        maxHeight: 30.0,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Text(
                              'Other Attributes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ..._menuItem!.otherAttributes.map(
                            (e) => CheckboxListTile(
                              title: Text(e.key),
                              subtitle:
                                  Text(e.priceAmendment.toStringAsFixed(2)),
                              value: _orderItemAttributes.indexWhere(
                                      (element) => element.key == e.key) >=
                                  0,
                              onChanged: (value) {
                                if (value == true) {
                                  setState(() {
                                    _orderItemAttributes.add(
                                      OrderItemAttribute(
                                          key: e.key,
                                          quantity: 1,
                                          priceAmendment: e.priceAmendment),
                                    );
                                  });
                                } else {
                                  setState(() {
                                    _orderItemAttributes.removeWhere(
                                        (element) => element.key == e.key);
                                  });
                                }
                              },
                            ),
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Other remarks',
                            ),
                            onChanged: (value) {
                              _remarks = value;
                            },
                          )
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        final oldValue =
                                            int.parse(_quantityController.text);
                                        if (oldValue == 1) return;
                                        _quantityController.value =
                                            TextEditingValue(
                                                text:
                                                    (oldValue - 1).toString());
                                      },
                                      icon: const Icon(Icons.remove)),
                                  SizedBox(
                                    width: 16,
                                    child: TextField(
                                        controller: _quantityController),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        final oldValue =
                                            int.parse(_quantityController.text);
                                        _quantityController.value =
                                            TextEditingValue(
                                                text:
                                                    (oldValue + 1).toString());
                                      },
                                      icon: const Icon(Icons.add)),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: _isDineIn ? 'Dine In' : 'Take Away',
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _isDineIn = newValue == 'Dine In';
                                });
                              },
                              items: <String>[
                                'Dine In',
                                'Take Away'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            Expanded(
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : TextButton.icon(
                                      onPressed: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          if (int.parse(
                                                  _quantityController.text) <=
                                              0) {
                                            showErrorDialog(
                                                'Quantity must be greater or equal to 1',
                                                context);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            return;
                                          }
                                          if (Provider.of<Shop>(context,
                                                      listen: false)
                                                  .orderSessionId ==
                                              null) {
                                            final res = await showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    OrderSessionDialog(
                                                      shopId: widget.shopId,
                                                    ));
                                            if (res != true) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              return;
                                            }
                                          }
                                          if (!mounted) return;
                                          if (_isDineIn &&
                                              Provider.of<Shop>(context,
                                                          listen: false)
                                                      .myTableNumber ==
                                                  "") {
                                            await showErrorDialog(
                                                'Dine in items must have table number',
                                                context);
                                            if(!mounted) return;
                                            final res = await showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const EnterTableNumberDialog());
                                            if (!mounted) return;
                                            if (res != null) {
                                              Provider.of<Shop>(context,
                                                      listen: false)
                                                  .orderSessionId = res;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            return;
                                          }
                                          for (var option
                                              in _menuItem!.options) {
                                            final choice =
                                                _optionsMap[option.name];
                                            if (choice == null) {
                                              showErrorDialog(
                                                  "Must select a choice for ${option.name}",
                                                  context);
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              return;
                                            }
                                            final optionIndex =
                                                _orderItemAttributes
                                                    .indexWhere((element) =>
                                                        element.key
                                                            .split(':')[0] ==
                                                        option.name);
                                            if (optionIndex < 0) {
                                              _orderItemAttributes.add(
                                                OrderItemAttribute(
                                                  key:
                                                      '${option.name}:  $choice',
                                                  quantity: 1,
                                                  priceAmendment: option.choices
                                                      .firstWhere((element) =>
                                                          element.key == choice)
                                                      .priceAmendment,
                                                ),
                                              );
                                            } else {
                                              _orderItemAttributes[
                                                      optionIndex] =
                                                  OrderItemAttribute(
                                                key: '${option.name}:  $choice',
                                                quantity: 1,
                                                priceAmendment: option.choices
                                                    .firstWhere((element) =>
                                                        element.key == choice)
                                                    .priceAmendment,
                                              );
                                            }
                                          }
                                          final addOnPrice =
                                              _orderItemAttributes.isEmpty
                                                  ? 0
                                                  : _orderItemAttributes
                                                      .map((e) =>
                                                          e.priceAmendment)
                                                      .reduce(
                                                          (value, element) =>
                                                              value + element);
                                          final subtotal =
                                              (_menuItem!.price + addOnPrice) *
                                                  int.parse(
                                                      _quantityController.text);
                                          if (!mounted) return;
                                          await Provider.of<Shop>(context,
                                                  listen: false)
                                              .addItemToOrderSession(
                                                  widget.shopId,
                                                  _menuItem!.title,
                                                  _menuItem!.id,
                                                  _isDineIn,
                                                  int.parse(
                                                      _quantityController.text),
                                                  _orderItemAttributes,
                                                  _remarks,
                                                  subtotal);
                                          widget.goBackToMenu();
                                        } catch (error) {
                                          showErrorDialog(
                                              error.toString(), context);
                                        }
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                      icon: const Icon(Icons.shopping_cart),
                                      label: const Text('Add to Cart')),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }),
      );
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
