import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_qrcode_modal_dart/walletconnect_qrcode_modal_dart.dart';
import 'package:walletconnect_secure_storage/walletconnect_secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class WalletConnectEthereumCredentials extends CustomTransactionSender {
  WalletConnectEthereumCredentials({required this.provider});

  final EthereumWalletConnectProvider provider;

  @override
  Future<EthereumAddress> extractAddress() {
    // TODO: implement extractAddress
    throw UnimplementedError();
  }

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final hash = await provider.sendTransaction(
      from: transaction.from!.hex,
      to: transaction.to?.hex,
      data: transaction.data,
      gas: transaction.maxGas,
      gasPrice: transaction.gasPrice?.getInWei,
      value: transaction.value?.getInWei,
      nonce: transaction.nonce,
    );

    return hash;
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToSignature

    throw UnimplementedError();
  }

  @override
  // TODO: implement address
  EthereumAddress get address => throw UnimplementedError();

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }
}

class Auth with ChangeNotifier {
  // Define a session storage
  final _sessionStorage = WalletConnectSecureStorage();
  WalletConnect? _connector;
  final _rpcClient = Web3Client(
    'https://bfdrpc.wmtech.cc',
    http.Client(),
  );
  WalletConnectQrCodeModal? _qrCodeModal;
  EthereumWalletConnectProvider? _provider;
  SessionStatus? _session;
  String? _uri;

  bool get isAuth => _session != null;
  String? get account => _session?.accounts[0];
  String? get networkName =>
      _session != null ? _getNetworkName(_session!.chainId) : null;
  Web3Client get rpcClient => _rpcClient;
  EthereumWalletConnectProvider? get provider => _provider;

  Future<bool> tryAutoLogin() async {
    try {
      final session = await _sessionStorage.getSession();
      if (session == null) return false;
      _connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        session: session,
        sessionStorage: _sessionStorage,
        clientMeta: const PeerMeta(
          name: 'My App',
          description: 'An app for converting pictures to NFT',
          url: 'https://walletconnect.org',
          icons: [
            'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
      );
      _connector!.on('connect', (session) {
        _session = _session;
        notifyListeners();
      });
      _connector!.on('session_update', (payload) {
        _session = payload as SessionStatus?;
        notifyListeners();
      });
      _connector!.on('disconnect', (payload) {
        _session = null;
        notifyListeners();
      });
      _session = await _connector!.connect();
      _provider = EthereumWalletConnectProvider(_connector!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> openWalletApp() async {
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (isWebMobile) {
      launchUrlString(_uri!, mode: LaunchMode.externalApplication);
    } else {
      await _qrCodeModal?.openWalletApp();
    }
  }

  Future<double?> getBalance() async {
    if (_connector == null) return null;
    final address = EthereumAddress.fromHex(_connector!.session.accounts[0]);
    final amount = await _rpcClient.getBalance(address);
    return amount.getValueInUnit(EtherUnit.ether).toDouble();
  }

  bool validateAddress({required String address}) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  String get faucetUrl => 'https://faucet.dimensions.network/';

  String? get address => _connector?.session.accounts[0];

  String get coinName => 'Eth';

  String _getNetworkName(int chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goreli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      case 80001:
        return 'Mumbai Testnet';
      default:
        return 'Unknown Chain';
    }
  }

  Future<void> login(BuildContext context) async {
    if (_connector?.connected ?? false) {
      throw Exception("Connector already connected");
    }
    _connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      sessionStorage: _sessionStorage,
      clientMeta: const PeerMeta(
        name: 'My App',
        description: 'An app for converting pictures to NFT',
        url: 'https://walletconnect.org',
        icons: [
          'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (isWebMobile) {
      final session =
          await _connector!.createSession(onDisplayUri: (uri) async {
        _uri = uri;
        await launchUrlString(uri, mode: LaunchMode.externalApplication);
      });
      _connector!.on('connect', (session) {
        _session = _session;
        notifyListeners();
      });
      _connector!.on('session_update', (payload) {
        _session = payload as SessionStatus?;
        notifyListeners();
      });
      _connector!.on('disconnect', (payload) {
        _session = null;
        notifyListeners();
      });

      print(session.accounts[0]);
      print(session.chainId);
      _session = session;
    } else {
      _qrCodeModal = WalletConnectQrCodeModal(connector: _connector);
      // Subscribe to events
      _qrCodeModal!.registerListeners(
        onConnect: (session) => print('Connected: $session'),
        onSessionUpdate: (WCSessionUpdateResponse response) {
          print('Session updated: $response');
        },
        onDisconnect: () {
          _session = null;
          print('Disconnected');
          notifyListeners();
        },
      );

      // Create QR code modal and connect to a wallet, connector returns WalletConnect
      // session which can be saved and restored.
      final session = await _qrCodeModal!
          .connect(context)
          // Errors can also be caught from connector, eg. session cancelled
          .catchError((error) {
        // Handle error here
        debugPrint(error);
        return null;
      });
      if (session == null) return;
      print(session.accounts[0]);
      print(session.chainId);
      _session = session;
    }

    _provider = EthereumWalletConnectProvider(_connector!);
    notifyListeners();
  }

  Future<String?> sendTestingAmount({
    required String recipientAddress,
    required double amount,
  }) async {
    if (!(_connector?.connected ?? true)) return null;
    final sender = EthereumAddress.fromHex(_connector!.session.accounts[0]);
    final recipient = EthereumAddress.fromHex(address!);

    final etherAmount =
        EtherAmount.fromInt(EtherUnit.szabo, (amount * 1000 * 1000).toInt());

    final transaction = Transaction(
      to: recipient,
      from: sender,
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: etherAmount,
    );

    final credentials = WalletConnectEthereumCredentials(provider: _provider!);

    // Sign the transaction
    try {
      final txBytes =
          await _rpcClient.sendTransaction(credentials, transaction);
      return txBytes;
    } catch (e) {
      debugPrint('Error: $e');
    }

    // Kill the session
    // _connector.killSession();

    return null;
  }

  Future<void> killSession() async {
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (isWebMobile) {
      await _connector?.killSession();
    } else {
      await _connector?.killSession();
      await _qrCodeModal?.killSession();
    }
    await _sessionStorage.removeSession();
    notifyListeners();
  }

  Future<String?> signMessage(String message) async {
    if (!(_connector?.connected ?? true)) {
      throw Exception("Connector not connected");
    }
    print("Message received");
    print(message);

    var signature =
        await _provider!.sign(message: message, address: _session!.accounts[0]);
    print(signature);
    return signature;
  }
}
