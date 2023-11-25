import 'package:flutter/material.dart';

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805);

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final int maxLines;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final ValueChanged<String?>? onDropdownChanged;

  CustomTextField({
    this.controller,
    required this.label,
    this.maxLines = 1,
    this.isDropdown = false,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  FocusNode _dropdownFocusNode = FocusNode();
  bool _isFocused = false;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _dropdownFocusNode.addListener(() {
      setState(() {
        _isFocused = _dropdownFocusNode.hasFocus;
      });
    });
  }


  @override
  void dispose() {
    _focusNode.dispose();
    _dropdownFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: widget.isDropdown
          ? GestureDetector(
        onTap: () {
          setState(() {
            _isDropdownOpen = true;
          });
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 70),  // Ensure the button has a certain height
          child: DropdownButtonFormField(
            value: widget.dropdownValue,
            items: widget.dropdownItems?.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (value) {
              widget.onDropdownChanged!(value);
              setState(() {
                _isDropdownOpen = false; // Close dropdown state
              });
            },
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                color: _isDropdownOpen ? primaryColor : backgroundColor,  // Change this line
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: backgroundColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: backgroundColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
        ),
      )
          : TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused ? primaryColor : backgroundColor,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: backgroundColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: backgroundColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        maxLines: widget.maxLines,
      ),
    );
  }
}
