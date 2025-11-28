import 'package:flutter_leopard_demo/examples/music/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';



class ConnectionForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ipController;
  final TextEditingController portController;

  const ConnectionForm({
    super.key,
    required this.formKey,
    required this.ipController,
    required this.portController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: ipController,
            labelText: 'Host / IP',
            hintText: 'e.g. 192.168.1.100 or localhost',
            prefixIcon: Icons.router,
            textInputAction: TextInputAction.next,
            validator: _validateHost,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: portController,
            labelText: 'Port',
            hintText: '6600',
            prefixIcon: Icons.lan,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: _validatePort,
          ),
        ],
      ),
    );
  }

  // ---- 校验逻辑抽出来，代码更干净 ----

  String? _validateHost(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter host / IP address';
    }

    // 允许 localhost / 普通域名
    if (text == 'localhost') return null;

    // 简单校验 IPv4，避免太复杂的正则 + 依然保持宽松
    if (_isValidIPv4(text)) {
      return null;
    }

    // 可以稍微宽容一点：允许常见 hostname（字母数字、中划线、点）
    final hostnameReg = RegExp(r'^[a-zA-Z0-9][-a-zA-Z0-9.]*$');
    if (hostnameReg.hasMatch(text)) {
      return null;
    }

    return 'Please enter a valid host or IPv4 address';
  }

  String? _validatePort(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter port number';
    }
    final port = int.tryParse(text);
    if (port == null || port < 1 || port > 65535) {
      return 'Please enter a valid port (1-65535)';
    }
    return null;
  }

  bool _isValidIPv4(String input) {
    // 粗略 IPv4 校验：4 段 0~255
    final parts = input.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) {
        return false;
      }
    }
    return true;
  }
}





// class ConnectionForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController ipController;
//   final TextEditingController portController;
//
//   const ConnectionForm({
//     super.key,
//     required this.formKey,
//     required this.ipController,
//     required this.portController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: Column(
//         children: [
//           CustomTextField(
//             controller: ipController,
//             labelText: 'IP Address',
//             hintText: '192.168.1.100',
//             prefixIcon: Icons.router,
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Please enter IP address';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             controller: portController,
//             labelText: 'Port',
//             hintText: '6600',
//             prefixIcon: Icons.lan,
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Please enter port number';
//               }
//               final port = int.tryParse(value.trim());
//               if (port == null || port < 1 || port > 65535) {
//                 return 'Please enter a valid port (1-65535)';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
