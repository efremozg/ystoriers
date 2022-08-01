import 'package:flutter/material.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/country_codes.dart';

class CountryPage extends StatelessWidget {
  final Function(String countryCode) onSelect;
  const CountryPage({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Text(
              'Выберите страну',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                'Все страны',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ScaleButton(
                duration: const Duration(milliseconds: 100),
                onTap: () {
                  // onSelect(codes[index]
                  //     .entries
                  //     .firstWhere((element) => element.key == 'dial_code')
                  //     .value);
                  Navigator.pop(
                      context,
                      codes[index]
                          .entries
                          .firstWhere((element) => element.key == 'dial_code')
                          .value);
                },
                bound: 0.02,
                child: ListTile(
                  trailing: Text(
                    codes[index]
                        .entries
                        .firstWhere((element) => element.key == 'dial_code')
                        .value,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  title: Text(
                    codes[index]
                        .entries
                        .firstWhere((element) => element.key == 'name')
                        .value,
                  ),
                ),
              ),
              childCount: codes.length,
            ),
          ),
        ],
      ),
    );
  }
}
