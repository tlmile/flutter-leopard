import 'package:flutter/material.dart';



class DialogButtons extends StatelessWidget {
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onCancel;

  /// 文案可配置，默认还是 Cancel / Connect
  final String cancelLabel;
  final String connectLabel;

  const DialogButtons({
    super.key,
    required this.isConnecting,
    required this.onConnect,
    required this.onCancel,
    this.cancelLabel = 'Cancel',
    this.connectLabel = 'Connect',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const buttonPadding = EdgeInsets.symmetric(vertical: 16);
    final borderRadius = BorderRadius.circular(12);

    return Row(
      children: [
        /// Cancel - 次级动作，用 OutlinedButton 更合适
        Expanded(
          child: OutlinedButton(
            onPressed: isConnecting ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Text(
              cancelLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        /// Connect - 主动作，用 FilledButton
        Expanded(
          child: FilledButton(
            onPressed: isConnecting ? null : onConnect,
            style: FilledButton.styleFrom(
              padding: buttonPadding,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            child: isConnecting
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimary,
                ),
              ),
            )
                : Text(
              connectLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}








// class DialogButtons extends StatelessWidget {
//   final bool isConnecting;
//   final VoidCallback onConnect;
//   final VoidCallback onCancel;
//
//   const DialogButtons({
//     super.key,
//     required this.isConnecting,
//     required this.onConnect,
//     required this.onCancel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextButton(
//             onPressed: isConnecting ? null : onCancel,
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: const BorderSide(color: Color(0xFF333333)),
//               ),
//             ),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.white.withValues(alpha: 0.6),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: isConnecting ? null : onConnect,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 0,
//             ),
//             child: isConnecting
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
//                     ),
//                   )
//                 : const Text(
//                     'Connect',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
// }
