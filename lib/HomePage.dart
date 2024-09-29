import 'package:flutter/material.dart';
import 'package:reown_appkit/modal/widgets/text/appkit_address.dart';
import 'package:reown_appkit/reown_appkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ReownAppKitModal? appKitModal;
  String walletAddress = '';

  @override
  void initState() {
    super.initState();
    initializeAppKitModal();
  }

  void initializeAppKitModal() async {
    appKitModal = ReownAppKitModal(
      context: context,
      projectId: '2d5e262acbc9bf4a4ee3102881528534',
      metadata: const PairingMetadata(
        name: 'Crypto Flutter',
        description: 'A Crypto Flutter Example App',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'cryptoflutter://',
          universal: 'https://reown.com/crpytoflutter',
        ),
      ),
    );

    await appKitModal!.init();

    // Update wallet address if session is available
    updateWalletAddress();

    // Listen for session updates
    appKitModal!.addListener(() {
      updateWalletAddress();
    });

    setState(() {});
  }

  void updateWalletAddress() {
    // Check if the session is available and update wallet address
    if (appKitModal?.session != null) {
      setState(() {
        walletAddress = appKitModal!.session!.address ?? 'No Address';
      });
    } else {
      setState(() {
        walletAddress = 'No Address';
      });
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Crypto Flutter with ReownAppKit'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ito Network select button to choose the blockchain network.
          Visibility(
            visible: !appKitModal!.isConnected, //kapag !appKitModal! naman ay yan yung kapag hindi connected tsaka lalabas yan
            child: AppKitModalNetworkSelectButton(appKit: appKitModal!),
          ),
          const SizedBox(height: 16),

          // Connect/Disconnect Wallet button
          AppKitModalConnectButton(
            appKit: appKitModal!,
            custom: ElevatedButton(
              onPressed: () {
                if (appKitModal!.isConnected) {
                  // Add logic for disconnecting
                  appKitModal!.disconnect(); //  Ito yung method for disconnecting
                } else {
                  appKitModal!.openModalView(); // Open connection modal
                }
              },
              child: Text(appKitModal!.isConnected ? 'DISCONNECT WALLET' : 'CONNECT WALLET'),
            ),
          ),
          const SizedBox(height: 16),

          // Display Wallet Address
          Text(
            'Wallet Address: $walletAddress',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Display Balance
          ValueListenableBuilder<String>(
            valueListenable: appKitModal!.balanceNotifier,
            builder: (_, balance, __) {
              return Text('Balance: $balance');
            },
          ),
          const SizedBox(height: 16),

          // Custom buttons (Send and Receive) ay lalabas lang kapag connected na appKitModal!.isConnected ang ginamit ko :P
          Visibility(
            visible: appKitModal!.isConnected,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSendDialog(context); // 
                  },
                  child: const Text('Send'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Define what happens when the Receive button is pressed
                  },
                  child: const Text('Receive'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showSendDialog(BuildContext context) {
  final TextEditingController addressController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Recipient Address Starts with (0x..)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //const Text('Recipient Address Starts with (0x..)'),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Input Address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {

              
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
}