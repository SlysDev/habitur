import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';

const double _graphicSize = 60;

class BasicDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const BasicDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kBackgroundColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.data?['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              request.data?['description'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.data?['secondaryButtonTitle'] != null)
                  TextButton(
                    onPressed: () => completer(DialogResponse(
                      confirmed: false,
                    )),
                    child: Text(
                      request.data?['secondaryButtonTitle']!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                TextButton(
                  onPressed: () => completer(DialogResponse(
                    confirmed: true,
                  )),
                  child: Text(
                    request.data?['mainButtonTitle'] ?? 'Ok',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
