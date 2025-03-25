import 'package:flutter/cupertino.dart';

class MessageDialogButton extends StatelessWidget {
  final String label;
  final String message;

  const MessageDialogButton({
    Key? key,
    required this.label,
    required this.message, required String title,
  }) : super(key: key);
 
  void _showMessage(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Información"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: CupertinoButton(
        padding: const EdgeInsets.all(12),
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        onPressed: () => _showMessage(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CupertinoColors.systemBlue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
