import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class SendMessageBottom extends StatefulWidget {
  const SendMessageBottom({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SendMessageBottom> {
  final _buttonController = RoundedLoadingButtonController();
  var onPressed = false;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return Container(
      height: 600,
      width: double.infinity,
      padding: MediaQuery.of(context).viewInsets,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Container(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 15),
                Container(
                  height: 3,
                  width: 30,
                  decoration: BoxDecoration(
                    color: greyClose,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 15),
                const CustomTextField(hint: 'Поиск', search: true),
                const SizedBox(height: 15),
                Expanded(
                  child: SizedBox(
                    height: 380,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => _chatCard(),
                      itemCount: 6,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 1],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 35,
                      child: CustomTextField(
                        hint: 'Напишите сообщение',
                        search: false,
                        color: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: AccentButton(
                        onTap: () {},
                        controller: _buttonController,
                        title: 'Отправить',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatCard() {
    return ScaleButton(
      onTap: () {},
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      child: Container(
        color: Colors.white,
        height: 70,
        width: double.infinity,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 15),
                Image.asset(
                  'assets/account.png',
                  height: 50,
                  width: 50,
                ),
                const SizedBox(width: 15),
                const SizedBox(
                  height: 17,
                  child: Text(
                    'Ruffles',
                    style: TextStyle(fontFamily: 'SF UI', fontSize: 14),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 15),
                child: !onPressed
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            onPressed = true;
                          });
                        },
                        child: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                              shape: BoxShape.circle),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            onPressed = false;
                          });
                        },
                        child: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey,
                            ),
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
