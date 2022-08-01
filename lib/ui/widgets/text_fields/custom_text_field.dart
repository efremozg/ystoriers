import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SeacrhTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function()? onTap;
  final bool parameters;
  const SeacrhTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.parameters,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          width: 0.5,
          color: Colors.white,
        ),
      ),
      child: TextField(
        onChanged: (text) {},
        onTap: onTap,
        controller: controller,
        // textAlignVertical: TextAlignVertical.center,
        cursorHeight: 16,
        cursorColor: Theme.of(context).primaryColor,
        // style: GoogleFonts.roboto(
        //   fontSize: 16,
        //   fontWeight: FontWeight.w400,
        //   color: const Color.fromRGBO(51, 51, 51, 1),
        // ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.only(top: 12, right: 12),
          filled: true,
          fillColor: Colors.black,
          enabled: false,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 11,
            maxHeight: 11,
            maxWidth: 41,
          ),
          suffixIcon: parameters
              ? Container(
                  width: 70,
                  height: 25,
                  margin: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/close.svg',
                        height: 11.78,
                        width: 11.78,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 1,
                          height: 20,
                          color: const Color.fromRGBO(189, 189, 189, 1),
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/slider.svg',
                        height: 25,
                        width: 25,
                      ),
                    ],
                  ),
                )
              : null,
          prefixIcon: const Icon(null),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.white,
              style: BorderStyle.solid,
            ),
          ),
          hintStyle: TextStyle(color: Colors.white, fontSize: 14),
          hintText: hint,
        ),
      ),
    );
  }
}
