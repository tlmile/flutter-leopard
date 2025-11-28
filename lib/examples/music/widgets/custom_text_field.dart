import 'package:flutter/material.dart';




class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  /// 新增的一些常用配置（都有默认值，不影响旧代码）
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final bool enabled;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 封装一个基础边框，方便根据状态复用
    OutlineInputBorder _buildBorder(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1),
      );
    }

    final baseBorderColor = colors.outlineVariant.withOpacity(0.8);
    final focusedBorderColor = colors.primary;
    final errorBorderColor = colors.error;
    final fillColor = const Color(0xFF1A1A1A); // 保留你原来的暗色风格

    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: fillColor,
        isDense: true,
        contentPadding: const EdgeInsets.all(16),

        // 这里用 OutlineInputBorder + 各种状态颜色
        border: _buildBorder(baseBorderColor),
        enabledBorder: _buildBorder(baseBorderColor),
        focusedBorder: _buildBorder(focusedBorderColor),
        disabledBorder:
        _buildBorder(baseBorderColor.withOpacity(0.5)),
        errorBorder: _buildBorder(errorBorderColor),
        focusedErrorBorder: _buildBorder(errorBorderColor),
      ),
    );
  }
}








// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final String hintText;
//   final IconData prefixIcon;
//   final TextInputType? keyboardType;
//   final String? Function(String?)? validator;
//
//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.labelText,
//     required this.hintText,
//     required this.prefixIcon,
//     this.keyboardType,
//     this.validator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF333333)),
//       ),
//       child: TextFormField(
//         controller: controller,
//         style: const TextStyle(color: Colors.white),
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: labelText,
//           labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
//           prefixIcon: Icon(
//             prefixIcon,
//             color: Colors.white.withValues(alpha: 0.7),
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.all(16),
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }
