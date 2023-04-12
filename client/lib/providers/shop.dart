import 'dart:convert';
import 'dart:math';

import 'package:beautifood_lite/providers/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class MenuItemOption {
  final String name;
  final List<MenuItemOptionChoice> choices;
  const MenuItemOption(this.name, this.choices);
}

class MenuItemOptionChoice {
  final String key;
  final double priceAmendment;
  const MenuItemOptionChoice(this.key, this.priceAmendment);
}

class MenuItemAttributes {
  final String key;
  final double priceAmendment;
  const MenuItemAttributes(this.key, this.priceAmendment);
}

class MenuTime {
  final int day;
  final int start;
  final int end;
  const MenuTime(this.day, this.start, this.end);
}

class MenuItem {
  final String id;
  final String menuId;
  String title;
  String description;
  double price;
  bool inStock;
  bool isDineIn;
  bool isTakeAway;
  bool isPreferred;
  String category;
  String subcategory;
  List<String> tags;
  List<MenuItemOption> options;
  List<MenuItemAttributes> otherAttributes;
  List<String> imageUrls;
  List<MenuTime> availableTimes;
  int index;
  DateTime createdAt;
  DateTime updatedAt;
  MenuItem({
    required this.id,
    required this.menuId,
    required this.title,
    required this.description,
    required this.price,
    required this.inStock,
    required this.isDineIn,
    required this.isTakeAway,
    required this.isPreferred,
    required this.category,
    required this.subcategory,
    required this.tags,
    required this.options,
    required this.otherAttributes,
    required this.imageUrls,
    required this.availableTimes,
    required this.index,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Currency {
  final String name;
  final String symbol;
  const Currency(this.name, this.symbol);
}

class ShopData {
  final String id;
  String name;
  String description;
  String address;
  Currency currency;
  ShopData({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.currency,
  });
}

class MenuCategory {
  final String name;
  final List<String> subcategories;
  const MenuCategory(this.name, this.subcategories);
}

class ShopMenu {
  final String id;
  final String shopId;
  String title;
  String description;
  List<MenuCategory> categories;
  List<MenuTime> availableTimes;
  ShopMenu({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.categories,
    required this.availableTimes,
  });
}

class Order {
  final String id;
  final String shopId;
  // final String sessionId;
  final String userId;
  List<OrderItem> orderItems;
  String tableNumber;
  String remarks;
  List<OrderStatus> status;
  Order({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.orderItems,
    required this.tableNumber,
    required this.remarks,
    required this.status,
  });
}

class OrderItem {
  final String id;
  final String shopId;
  bool isDineIn;
  String tableNumber;
  String name;
  final String menuItemId;
  int quantity;
  List<OrderItemAttribute> otherAttributes;
  String remarks;
  double subtotal;
  DateTime? confirmedTime;
  DateTime? preparedTime;
  DateTime? deliveredTime;
  String? cancelMessage;
  String? paymentId;
  OrderItem({
    required this.id,
    required this.shopId,
    required this.isDineIn,
    required this.tableNumber,
    required this.name,
    required this.menuItemId,
    required this.quantity,
    required this.otherAttributes,
    required this.remarks,
    required this.subtotal,
    this.confirmedTime,
    this.preparedTime,
    this.deliveredTime,
    this.cancelMessage,
    this.paymentId,
  });
}

class OrderStatus {
  final String name;
  final String message;
  final String by;
  final DateTime time;
  const OrderStatus(this.name, this.message, this.by, this.time);
}

class OrderItemAttribute {
  final String key;
  final int quantity;
  final double priceAmendment;
  const OrderItemAttribute({
    required this.key,
    required this.quantity,
    required this.priceAmendment,
  });
}

class Shop with ChangeNotifier {
  Auth? _auth;
  String? _selectedShopId;
  List<MenuItem>? _menuItems;
  String? _selectedMenuItemId;
  ShopData? _shopData;
  ShopMenu? _shopMenu;

  String? _myTableNumber;
  Order? _currentOrder;

  Shop(Auth? auth) {
    _auth = auth;
  }
  void updateAuth(Auth auth) => _auth = auth;

  List<MenuItem>? get menuItems => _menuItems;
  String? get selectedShopId => _selectedShopId;
  set selectedShopId(String? id) {
    _selectedShopId = id;
    notifyListeners();
  }

  String? get selectedMenuItemId => _selectedMenuItemId;
  set selectedMenuItemId(String? id) {
    _selectedMenuItemId = id;
    notifyListeners();
  }

  String? get orderSessionId => _currentOrder?.id;
  set orderSessionId(String? id) {
    if (_currentOrder != null) {
      clearOrderSession();
    }
    newOrder(null, id);
    notifyListeners();
  }

  ShopData? get shopData => _shopData;
  ShopMenu? get shopMenu => _shopMenu;
  String? get myTableNumber => _myTableNumber;
  Order? get currentOrder => _currentOrder;

  Future<void> getShop() async {
    // dummy data
    final abi =
        await rootBundle.loadString('assets/contracts/BeautifoodL2.abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'BeautifoodL2'),
      EthereumAddress.fromHex('0xAfC45Ef7d4BA01c531E3F26676832B81dD77bD4B'),
    );
    final function = contract.function("getMenu");
    final result = await _auth!.rpcClient.call(
        contract: contract,
        function: function,
        params: [
          EthereumAddress.fromHex('0x41C929802517f5CE1eD0d6684B579F6E44d277b5')
        ]);
    print(result);
    final allTimes = [
      const MenuTime(0, 0, 24 * 60),
      const MenuTime(1, 0, 24 * 60),
      const MenuTime(2, 0, 24 * 60),
      const MenuTime(3, 0, 24 * 60),
      const MenuTime(4, 0, 24 * 60),
      const MenuTime(5, 0, 24 * 60),
      const MenuTime(6, 0, 24 * 60),
    ];
    _shopData = ShopData(
      id: "123456",
      name: "Jomluz Shop",
      description: "Selling western delicacies",
      address: "1, Jalan 2, Taman 3",
      currency: const Currency("MYR", "RM"),
    );
    _shopMenu = ShopMenu(
      id: "123457",
      shopId: "123456",
      title: "All-day menu",
      description: "Shop all day menu",
      categories: const [
        MenuCategory("Appetisers", ["Salad", "Soup"]),
        MenuCategory("Main Course", ["Pasta", "Steaks"]),
        MenuCategory("Desserts", ["Cakes", "Ice Creams"]),
      ],
      availableTimes: allTimes,
    );
    _menuItems = [
      MenuItem(
        id: "000001",
        menuId: "123457",
        title: "Fruit Salad",
        description: "Salad with seasonal fruits",
        price: 14.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Appetisers",
        subcategory: "Salad",
        tags: ["Salad"],
        options: [],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MenuItem(
        id: "000002",
        menuId: "123457",
        title: "Mushroom Soup",
        description: "Homemade fresh mushroom soup",
        price: 14.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Appetisers",
        subcategory: "Soup",
        tags: ["Soup"],
        options: [],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MenuItem(
        id: "000003",
        menuId: "123457",
        title: "Spaghetti Carbonara",
        description: "Signature Carbonara Pasta served with bacon and cheese.",
        price: 19.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Main Course",
        subcategory: "Pasta",
        tags: ["Pasta"],
        options: [],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MenuItem(
        id: "000004",
        menuId: "123457",
        title: "Rib-eye Steak",
        description: "Signature rib-eye steak served with sauce of your choice",
        price: 14.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Main Course",
        subcategory: "Steaks",
        tags: ["Steaks"],
        options: [
          const MenuItemOption(
            "Sauce",
            [
              MenuItemOptionChoice("Mushroom", 0.0),
              MenuItemOptionChoice("Black Pepper", 0.0),
            ],
          ),
          const MenuItemOption(
            "Cooking Option",
            [
              MenuItemOptionChoice("Medium", 0.0),
              MenuItemOptionChoice("Medium-Well", 0.0),
              MenuItemOptionChoice("Well Done", 0.0),
            ],
          ),
        ],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MenuItem(
        id: "000005",
        menuId: "123457",
        title: "Baked Cheese Cake",
        description: "Daily fresh baked cheese cake",
        price: 9.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Desserts",
        subcategory: "Cakes",
        tags: ["Cakes"],
        options: [],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MenuItem(
        id: "000006",
        menuId: "123457",
        title: "Matcha Ice Cream",
        description: "Matcha Ice Cream, the prefect dessert for your day.",
        price: 14.99,
        inStock: true,
        isDineIn: true,
        isTakeAway: true,
        isPreferred: false,
        category: "Desserts",
        subcategory: "Ice Creams",
        tags: ["Ice Creams"],
        options: [],
        otherAttributes: [],
        imageUrls: [],
        availableTimes: allTimes,
        index: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<MenuItem> getCategoryFoodItems(String category) {
    return menuItems
            ?.where((element) => element.category == category)
            .toList() ??
        [];
  }

  MenuItem? getMenuItem(String id) {
    return menuItems?.firstWhere((element) => element.id == id);
  }

  Future<void> addItemToOrderSession(
      String shopId,
      String title,
      String menuItemId,
      bool isDineIn,
      int quantity,
      List<OrderItemAttribute> otherAttributes,
      String remarks,
      double subtotal) async {
    if (_currentOrder == null) return;
    _currentOrder!.orderItems.add(
      OrderItem(
        id: createCryptoRandomString(24),
        shopId: shopId,
        isDineIn: isDineIn,
        tableNumber: _myTableNumber ?? "",
        name: title,
        menuItemId: menuItemId,
        quantity: quantity,
        otherAttributes: otherAttributes,
        remarks: remarks,
        subtotal: subtotal,
      ),
    );
    notifyListeners();
  }

  Future<void> removeItemFromOrderSession(
    String id,
  ) async {
    if (_currentOrder == null) return;
    _currentOrder!.orderItems.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> submitOrderItems(List<String> selectedOrderItems) async {
    final abi =
        await rootBundle.loadString('assets/contracts/BeautifoodL2.abi.json');
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'BeautifoodL2'),
      EthereumAddress.fromHex('0xAfC45Ef7d4BA01c531E3F26676832B81dD77bD4B'),
    );
    final function = contract.function("submitOrder");
    print("Preparing to send");
    final transaction = Transaction.callContract(
      from: EthereumAddress.fromHex(_auth!.address!),
      contract: contract,
      function: function,
      parameters: [
        [
          [BigInt.from(0), BigInt.from(2)],
          [BigInt.from(1), BigInt.from(3)],
        ],
        EthereumAddress.fromHex("0x41C929802517f5CE1eD0d6684B579F6E44d277b5")
      ],
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
    );
    print("Preparing to send.");
    final credentials =
        WalletConnectEthereumCredentials(provider: _auth!.provider!);

    // Sign the transaction
    print("Preparing to send..");
    try {
      final txBytes =
          await _auth!.rpcClient.sendTransaction(credentials, transaction);
      print(txBytes);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> newOrder(String? tableNumber, String? orderSessionId) async {
    _currentOrder = Order(
      id: orderSessionId ?? createCryptoRandomString(12),
      shopId: shopData!.id,
      userId: _auth!.address!,
      orderItems: [],
      tableNumber: tableNumber ?? "",
      remarks: "",
      status: [],
    );
    notifyListeners();
  }

  void clear() {
    _shopData = null;
    notifyListeners();
  }

  void clearOrderSession() {
    _currentOrder = null;
    _myTableNumber = null;
  }

  static String createCryptoRandomString([int length = 32]) {
    var values =
        List<int>.generate(length, (i) => Random.secure().nextInt(256));

    return base64Url.encode(values);
  }
}
