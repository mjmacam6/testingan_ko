import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/modal/widgets/text/appkit_address.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transaction_card.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ReownAppKitModal? appKitModal;
  String walletAddress = '';
  bool isLoading = false;
  List<TransactionDetails> transactions = []; 

  final customNetwork = ReownAppKitModalNetworkInfo(
    name: 'Sepolia',
    chainId: '11155111',
    currency: 'ETH',
    rpcUrl: 'https://rpc.sepolia.org/',
    explorerUrl: 'https://sepolia.etherscan.io/',
    isTestNetwork: true,
  );

  final String etherscanApiKey = '5KEE4GXQSGWAFCJ6CWBJPMQ5BV3VQ33IX1';
  @override
  void initState() {
    super.initState();
    initializeAppKitModal();
  }

  void initializeAppKitModal() async {
    ReownAppKitModalNetworks.addNetworks('eip155', [customNetwork]);
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
          universal: 'https://reown.com/cryptoflutter',
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
        fetchTransactions(walletAddress);
      });
    } else {
      setState(() {
        walletAddress = 'No Address';
      });
    }
  }

  Future<void> fetchTransactions(String address) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url =
          'https://api-sepolia.etherscan.io/api?module=account&action=txlist&address=$address&startblock=0&endblock=99999999&sort=desc&apikey=$etherscanApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == '1') {
          final txList = data['result'] as List;

          setState(() {
            transactions = txList
                .map((tx) => TransactionDetails(
                      sender: tx['from'],
                      recipient: tx['to'],
                      amount: (BigInt.parse(tx['value']) / BigInt.from(10).pow(18)).toString(),
                      hash: tx['hash'],
                    ))
                .toList();
          });
        } else {
          throw Exception('Failed to load transactions');
        }
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                title: const SizedBox.shrink(),
                background: Container(
                  color: const Color.fromARGB(255, 3, 169, 244),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            BalanceCard(balance: _balance, address: walletAddress),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const PaymentSectionTitle(title: 'Actions'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 16),
                          AppKitModalConnectButton(
                                appKit: appKitModal!,
                                custom: ElevatedButton(
                                  onPressed: () {
                                      if (appKitModal!.isConnected) {
                                        // Add logic for disconnecting
                                        appKitModal!.disconnect(); // Example method for disconnecting
                                      } else {
                                        appKitModal!.openModalView(); // Open connection modal
                                      }
                                    },
                                  child: Text(appKitModal!.isConnected ? 'Disconnect' : 'Connect Wallet'),
                                ),
                              ),
                          const SizedBox(height: 16),
                             Visibility(
                            visible: !appKitModal!.isConnected, //kapag !appKitModal! naman ay yan yung kapag hindi connected tsaka lalabas yan
                            child: AppKitModalNetworkSelectButton(appKit: appKitModal!),
                          ),
                          const SizedBox(height: 16),
                          Visibility(
                            visible: appKitModal!.isConnected,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                     _showSendDialog(context); // Show send dialog on press
                                  },
                                  child: const Text('Send'),
                                ),
                                const SizedBox(width: 17),
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
                    const PaymentSectionTitle(title: 'Transactions'),
                   Visibility(
                      visible: appKitModal!.isConnected,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Container(
                              height: 120, // Specify a fixed height as per your requirement
                              child: ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return PaymentJobCardPage(
                                    amount: transaction.amount,
                                    sender: transaction.sender,
                                    recipient: transaction.recipient,
                                    hash: transaction.hash,
                                  );
                                },
                              ),
                            ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'About Job',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.post_add),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment_outlined),
          label: 'Payment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JobPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostPage()),
            );
            break;
          case 3:
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}


  void _showSendDialog(BuildContext context) {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  showDialog(
    
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Send Crypto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Recipient Address (0x..)',
              ),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: 'Amount to Send',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String recipient = addressController.text;
              double amount = double.parse(amountController.text);
              BigInt bigIntValue = BigInt.from(amount * pow(10, 18));
              EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
              Navigator.of(context).pop();
              setState(() {
                  isLoading = true; 
                    print('gumana');
                      final Uri metamaskUri = Uri.parse("metamask://"); 
                  // Launch the MetaMask URI without checking
                      launchUrl(metamaskUri, mode: LaunchMode.externalApplication);

              });
              try {
                await sendTransaction(recipient, ethAmount); 
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
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

    
    Future<void> sendTransaction(String receiver, EtherAmount txValue) async {
    setState(() {
      isLoading = true;
    });

    final tetherContract = DeployedContract(
      ContractAbi.fromJson(
        jsonEncode([{
          "constant": false,
          "inputs": [
            {
              "internalType": "address",
              "name": "_to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "transfer",
          "outputs": [],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        }]), 
        'ETH',
      ),
      EthereumAddress.fromHex(receiver), 
    );

    try {
      final senderAddress = appKitModal!.session!.address!;
      final currentBalance = appKitModal!.balanceNotifier.value;

      if (currentBalance.isEmpty) {
        throw Exception('Unable to fetch wallet balance.');
      }

      BigInt balanceInWeiValue;
      try {
        // Convert the current balance from string to double, then to Wei
        double balanceInEther = double.parse(currentBalance.split(' ')[0]);
        balanceInWeiValue = BigInt.from((balanceInEther * pow(10, 18)).toInt());
      } catch (e) {
        throw Exception('Error parsing wallet balance: $e');
      }

      final balanceInWei = EtherAmount.fromUnitAndValue(
        EtherUnit.wei, balanceInWeiValue
      );

      // Calculate total cost including transaction fee
      final totalCost = txValue.getInWei + BigInt.from(100000 * 21000); 
      if (balanceInWei.getInWei < totalCost) {
        throw Exception('Insufficient funds for transaction!');
      }

      print('Sending transaction to $receiver with value $txValue');
      final result = await appKitModal!.requestWriteContract(
        topic: appKitModal!.session!.topic,
        chainId: appKitModal!.selectedChain!.chainId,
        deployedContract: tetherContract,
        functionName: 'transfer',
        transaction: Transaction(
          from: EthereumAddress.fromHex(senderAddress),
          to: EthereumAddress.fromHex(receiver),
          value: txValue,
          maxGas: 100000,
        ),
        parameters: [
          EthereumAddress.fromHex(receiver), 
          txValue.getInWei, 
        ],
      );  
      print('Transaction result: $result');

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction successful!')),
        );
        await appKitModal!.loadAccountData();
        print('Sender Address: $senderAddress');
        print('Recipient Address: $receiver');
        print('Amount Sent: ${txValue.getValueInUnit(EtherUnit.ether)} ETH');
      } else {
        throw Exception('Transaction failed. Please try again.');
      }
    } catch (e) {
      print('Error sending transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }
}
  

class TransactionDetails {
  final String sender;
  final String recipient;
  final String amount;
  final String hash;

  TransactionDetails({
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.hash,
  });
}

