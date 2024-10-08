// transaction_card.dart
import 'package:flutter/material.dart';

class TransactionCard extends StatefulWidget {
  final String amount;
  final String sender;
  final String recipient;
  final String hash;

  const TransactionCard({
    Key? key,
    required this.amount,
    required this.sender,
    required this.recipient,
    required this.hash,
  }) : super(key: key);

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isExpanded = false;

  // Helper function to shorten the address
  String shortenAddress(String address) {
    if (address.length <= 10) return address; // Return as is if too short
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded; // Toggle expanded state on tap
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SENT ${widget.amount} ETH',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text('From: ${_isExpanded ? widget.sender : shortenAddress(widget.sender)}'),
              Text('To: ${_isExpanded ? widget.recipient : shortenAddress(widget.recipient)}'),
              const SizedBox(height: 8),
              Text('Hash: ${_isExpanded ? widget.hash : shortenAddress(widget.hash)}'),
            ],
          ),
        ),
      ),
    );
  }
}
