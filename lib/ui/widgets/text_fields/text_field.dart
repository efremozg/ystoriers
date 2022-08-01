import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/country/country.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool search;
  final bool password;
  final TextInputType type;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Color? color;
  final Function(String code)? onSelect;
  final TextEditingController? controller;
  final List<TextInputFormatter>? formatters;
  const CustomTextField({
    Key? key,
    required this.hint,
    required this.search,
    this.onChanged,
    this.onTap,
    this.onSelect,
    this.formatters = const [],
    this.controller,
    this.password = false,
    this.color = const Color.fromRGBO(238, 238, 238, 1),
    this.type = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String code = '+7';
    var _streamController = StreamController<String>();
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      height: search ? 40 : 45,
      padding: !search
          ? type == TextInputType.phone
              ? EdgeInsets.zero
              : const EdgeInsets.only(left: 15)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color,
      ),
      width: double.infinity,
      child: type == TextInputType.phone
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => CountryPage(
                            onSelect: (countryCode) {
                              code = countryCode;
                            },
                          ),
                        ),
                      ).then((value) {
                        if (value is String) {
                          _streamController.sink.add(value);
                          onSelect!.call(value);
                        }
                      });
                    },
                    child: Container(
                      color: Colors.white.withOpacity(0),
                      child: Stack(
                        children: [
                          StreamBuilder<String>(
                              initialData: '+7',
                              stream: _streamController.stream,
                              builder: (context, snapshot) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    snapshot.data ?? '',
                                    style: TextStyle(
                                        color: accentColor, fontSize: 15),
                                  ),
                                );
                              }),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 0.3,
                              height: 45,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: _textField(),
                  ),
                ),
              ],
            )
          : _textField(),
    );
  }

  TextField _textField() {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: password,
      onChanged: (text) {
        if (onChanged != null) {
          onChanged!.call(text);
        }
      },
      inputFormatters: formatters,
      onTap: onTap,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 0,
        ),
        prefixIcon: search
            ? SizedBox(
                width: 24,
                child: Align(
                  child: SvgPicture.asset(
                    'assets/page_search.svg',
                    color: const Color.fromRGBO(158, 158, 158, 1),
                    width: 24,
                    height: 24,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        hintStyle: const TextStyle(fontSize: 14),
        hintText: hint,
      ),
    );
  }
}
