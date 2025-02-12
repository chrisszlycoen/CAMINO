import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CaminoTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final bool centerLabel;

  const CaminoTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.centerLabel = false,
  });

  @override
  State<CaminoTextField> createState() => _CaminoTextFieldState();
}

class _CaminoTextFieldState extends State<CaminoTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Aesthetic colors based on theme and focus
    final bgColor = isDark ? AppColors.surfaceDarkElevated : Colors.white;
    final borderColor = _isFocused 
        ? AppColors.primary 
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    
    final iconColor = _isFocused
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: widget.centerLabel ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Premium subtle label above the field
        Text(
          widget.label.toUpperCase(),
          textAlign: widget.centerLabel ? TextAlign.center : TextAlign.start,
          style: TextStyle( 
            color: hintColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        
        // The input container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2.0 : 1.0,
            ),
            boxShadow: _isFocused && !isDark ? AppColors.premiumShadowLight : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _isObscured,
            keyboardType: widget.keyboardType,
            textAlign: widget.textAlign,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: hintColor.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              prefixIcon: widget.prefixIcon != null 
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12),
                      child: Icon(widget.prefixIcon, color: iconColor, size: 22),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: iconColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
