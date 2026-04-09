import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TokenDisplay extends StatelessWidget {
  final String? token;

  const TokenDisplay({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.key, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Device Token (FCM)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (token != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy token',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Token copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                token ?? 'Loading token...',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: token != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
