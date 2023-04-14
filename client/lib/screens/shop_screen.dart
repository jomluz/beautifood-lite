import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beautifood_lite/providers/shop.dart';
import 'package:beautifood_lite/router/route_path.dart';
import 'package:beautifood_lite/widgets/food_title_widget.dart';
import 'package:beautifood_lite/widgets/join_order_session_dialog.dart';
import 'package:beautifood_lite/widgets/order_session_dialog.dart';
import 'package:beautifood_lite/widgets/show_qr_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:share_plus/share_plus.dart';

class ShopPath extends AppRoutePath {
  final String id;
  final String? tableNo;
  final String? sessionId;
  ShopPath(this.id, this.tableNo, this.sessionId);
  @override
  String getRouteInformation() {
    return sessionId != null
        ? '/shop/$id?sessionId=$sessionId'
        : tableNo != null
            ? '/shop/$id?tableNo=$tableNo'
            : '/shop/$id';
  }
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    Key? key,
    required this.id,
    required this.onSelectMenuItem,
    required this.onShowCart,
  }) : super(key: key);
  final String id;
  final Function(String) onSelectMenuItem;
  final Function() onShowCart;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  int _tabLength = 0;

  @override
  void initState() {
    _tabController = TabController(length: _tabLength, vsync: this);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    if (_tabController.length != _tabLength) {
      _tabController = TabController(length: _tabLength, vsync: this);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> getData(Shop shop) async {
    if (shop.shopData == null) {
      try {
        await shop.getShop();
      } catch (e) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Consumer<Shop>(builder: (context, shop, _) {
      return Scaffold(
        appBar: shop.shopData == null
            ? AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0.0,
                title: const Text(
                  'Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        // drawer: createDrawer(context),
        body: FutureBuilder(
            future: getData(shop),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (shop.shopData == null) {
                return const Center(
                  child: Text('Shop Not Found'),
                );
              }
              if (shop.menuItems == null) {
                return const Center(
                  child: Text('Shop Closed'),
                );
              }
              if (shop.orderSessionId == null) {
                if (Provider.of<Shop>(context, listen: false).myTableNumber !=
                    null) {
                  Future.delayed(
                      Duration.zero,
                      () => showDialog(
                            context: context,
                            builder: (ctx) => JoinOrderSessionDialog(
                                shopId: shop.selectedShopId!),
                          ));
                } else {
                  Future.delayed(
                      Duration.zero,
                      () => showDialog(
                            context: context,
                            builder: (ctx) => OrderSessionDialog(
                                shopId: shop.selectedShopId!),
                          ));
                }
              }
              _tabLength = shop.shopMenu?.categories.length ?? 0;
              if (_tabController.length != _tabLength) {
                _tabController = TabController(length: _tabLength, vsync: this);
              }
              return Center(
                child: SizedBox(
                  width: deviceSize.aspectRatio > 1
                      ? deviceSize.width * 0.6
                      : deviceSize.width * 0.9,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(shop.shopData?.name ?? ''),
                              if (Provider.of<Shop>(context).orderSessionId !=
                                  null)
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            'Session: ${Provider.of<Shop>(context, listen: false).orderSessionId}',
                                            maxLines: 2,
                                            textAlign: TextAlign.end,
                                            minFontSize: 8,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: IconButton(
                                          iconSize: 16,
                                          splashRadius: 12,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => ShowQRCodeDialog(
                                                  data:
                                                      'https://app.lite.beautifood.io/#/shop/${widget.id}?sessionId=${Provider.of<Shop>(context, listen: false).orderSessionId}', tableNo: shop.myTableNumber,),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.qr_code,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: IconButton(
                                          iconSize: 16,
                                          splashRadius: 12,
                                          onPressed: () {
                                            Share.share(
                                                'Join My Beautifood Order Session on ${shop.shopData?.name ?? ''}! https://app.lite.beautifood.io/#/shop/${widget.id}?sessionId=${Provider.of<Shop>(context, listen: false).orderSessionId} \n Session ID: ${Provider.of<Shop>(context, listen: false).orderSessionId}',
                                                subject:
                                                    'Join Beautifood Order Session!');
                                          },
                                          icon: const Icon(
                                            Icons.share,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        child: IconButton(
                                          iconSize: 16,
                                          splashRadius: 12,
                                          onPressed: () async {
                                            final res = await showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Are you sure?'),
                                                content: const Text(
                                                    'Are you sure to leave this order session?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx)
                                                            .pop(true),
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (res != true) {
                                              return;
                                            }
                                            if (!mounted) return;
                                            Provider.of<Shop>(context,
                                                    listen: false)
                                                .clearOrderSession();
                                          },
                                          icon: const Icon(
                                            Icons.exit_to_app,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          expandedHeight: null,
                          flexibleSpace: null),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          minHeight: 45.0,
                          maxHeight: 45.0,
                          child: Container(
                            color: const Color(0xfff5f5f5),
                            child: TabBar(
                                isScrollable: true,
                                controller: _tabController,
                                // unselectedLabelColor:
                                //     Colors.white.withOpacity(0.3),
                                tabs: shop.shopMenu!.categories
                                    .map((e) => Tab(
                                          child: AutoSizeText(
                                            e.name,
                                            maxLines: 2,
                                            wrapWords: false,
                                            minFontSize: 8,
                                          ),
                                        ))
                                    .toList()),
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: TabBarView(
                          controller: _tabController,
                          children: shop.shopMenu!.categories.map(
                            (category) {
                              final categoryItems =
                                  shop.getCategoryFoodItems(category.name);
                              if (category.subcategories.isEmpty) {
                                categoryItems.sort(
                                    (a, b) => (a.index).compareTo(b.index));
                              }
                              return category.subcategories.isNotEmpty
                                  ? CustomScrollView(
                                      shrinkWrap: true,
                                      slivers: [
                                        ...category.subcategories.map(
                                          (subcategory) {
                                            final subcategoryItems =
                                                categoryItems
                                                    .where((element) =>
                                                        element.subcategory ==
                                                        subcategory)
                                                    .toList();
                                            subcategoryItems.sort((a, b) =>
                                                (a.index).compareTo(b.index));
                                            return [
                                              SliverPersistentHeader(
                                                pinned: true,
                                                delegate: _SliverAppBarDelegate(
                                                  minHeight: 30.0,
                                                  maxHeight: 30.0,
                                                  child: Container(
                                                    color:
                                                        const Color(0xfff5f5f5),
                                                    child: Center(
                                                      child: Text(
                                                        subcategory,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SliverList(
                                                delegate:
                                                    SliverChildListDelegate(
                                                        subcategoryItems
                                                            .map(
                                                              (item) =>
                                                                  FoodTitleWidget(
                                                                      item,
                                                                      widget
                                                                          .onSelectMenuItem),
                                                            )
                                                            .toList()),
                                              ),
                                            ];
                                          },
                                        ).expand((x) => x),
                                      ],
                                    )
                                  : ListView.builder(
                                      itemCount: categoryItems.length,
                                      itemBuilder: (context, index) =>
                                          FoodTitleWidget(categoryItems[index],
                                              widget.onSelectMenuItem),
                                    );
                            },
                          ).toList(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                            height: 46.0,
                            child: Center(
                              child: Text(
                                'Copyright (c) 2022 JOMLUZ Tech Sdn Bhd. All rights reserved.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              );
            }),
        floatingActionButton: shop.currentOrder == null
            ? null
            : badges.Badge(
                showBadge: shop.currentOrder!.orderItems.isNotEmpty,
                badgeContent:
                    Text(shop.currentOrder!.orderItems.length.toString()),
                child: FloatingActionButton(
                  onPressed: () {
                    widget.onShowCart();
                  },
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
      );
    });
  }

  createSearchBar(BuildContext context) {
    return GestureDetector(
      // onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => const SearchScreen())),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: const Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Text(
                "Search",
                style: TextStyle(color: Colors.black45),
              ),
            )),
            Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.orange,
                    ),
                    onPressed: null)),
          ],
        ),
      ),
    );
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
