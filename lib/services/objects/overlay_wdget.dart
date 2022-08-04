import 'package:flutter/material.dart';
import 'package:y_storiers/services/constants.dart';

OverlayEntry createOverlayEntry() {
  return OverlayEntry(
      builder: (context) => Positioned(
            left: 10,
            top: 40,
            width: double.infinity,
            child: Material(
              elevation: 4.0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  width: 400,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                    // boxShadow: shadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SelectableText(
                            'Потеряно интернет соединение',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
}
