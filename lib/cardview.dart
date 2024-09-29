import 'package:flutter/material.dart';


class CardView extends StatelessWidget {
  final String address;

  const CardView({
    Key? key,
    required this.address,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected Address:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              address,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Balance:',
              style: Theme.of(context).textTheme.titleLarge,
            ),

          ],
        ),
      ),
    );
  }
}
