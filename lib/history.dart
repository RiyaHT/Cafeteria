import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_provider.dart';
import 'dio_singleton.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> items = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<dynamic> item = [];
  List transactions = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime selectedDate = DateTime.now();
  String? selectedValue;
  String? selectedYear;
  var userId;
  Dio dio = DioSingleton.dio;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedYear = DateFormat('yyyy').format(selectedDate);
    selectedValue = items[int.parse(DateFormat('MM').format(selectedDate)) - 1];
    _prefs.then((SharedPreferences pref) => {
          getEmployeeData(pref.getInt('puserId')),
          userId = pref.getInt('puserId')
        });
    List tempItems = [];
    for (int i = 0; i < 3; i++) {
      int year = int.parse(DateFormat('yyyy').format(selectedDate)) - i;
      tempItems.add(year);
    }

    setState(() {
      item = tempItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white12,
                  ],
                ),
              ),
            ),
            shape: const Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(112, 12, 121, 1), width: 2)),
            title: const Text(
              "Payment History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(112, 12, 121, 1),
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: const Icon(Icons.arrow_back),
              color: const Color.fromRGBO(112, 12, 121, 1),
            )),
        body: Stack(children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(112, 12, 121, 0.55),
                  Color.fromRGBO(63, 166, 235, 0.55)
                ],
              ),
            ),
            child: Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(42, 4, 49, 0.4),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 2.0, //extend the shadow
                      offset: Offset(
                        5.0, // Move to right 5  horizontally
                        5.0, // Move to bottom 5 Vertically
                      ),
                    ),
                  ],
                ),
                child: Column(children: [
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Change Year : ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(112, 12, 121, 1),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: item
                                        .map((item) =>
                                            DropdownMenuItem<dynamic>(
                                              value: item.toString(),
                                              child: Text(
                                                item.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      112, 12, 121, 1),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedYear,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedYear = value;
                                        getEmployeeData(userId, year: value);
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      width: 120,
                                      height: 30,
                                      padding: const EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              112, 12, 121, 0.3),
                                          width: 2,
                                        ),
                                        color: Colors.white,
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.expand_more,
                                      ),
                                      iconSize: 14,
                                      iconEnabledColor:
                                          Color.fromRGBO(112, 12, 121, 1),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Change Month : ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(112, 12, 121, 1),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: items
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      112, 12, 121, 1),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value;
                                        getEmployeeData(userId, month: value);
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      width: 120,
                                      height: 30,
                                      padding: const EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color.fromRGBO(
                                              112, 12, 121, 0.3),
                                          width: 2,
                                        ),
                                        color: Colors.white,
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.expand_more,
                                      ),
                                      iconSize: 14,
                                      iconEnabledColor:
                                          Color.fromRGBO(112, 12, 121, 1),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]),
                  Container(
                    height: 15,
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color.fromRGBO(112, 12, 121, 0.5),
                                width: 2))),
                  ),
                  Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: transactions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                112, 12, 121, 0.05),
                                            width: 2))),
                                child: Column(children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Text(
                                            'Transaction ID: ${transactions[index]['walletTranscId']} ',
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    112, 12, 121, 1)),
                                          ),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Location: ${transactions[index]['location']} ',
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          112, 12, 121, 1)),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  'Date: ${transactions[index]['transactionDate'].split(' ')[0]} ',
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          112, 12, 121, 1)),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  'Time: ${transactions[index]['transactionDate'].split(' ')[1]} ',
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          112, 12, 121, 1)),
                                                ),
                                              ]),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(right: 0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  ' ₹ ${transactions[index]['amount']} ',
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          112, 12, 121, 1)),
                                                ),
                                              ]),
                                        ),
                                      ]),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ]));
                          })),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Scroll for more transaction details ',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 12, 121, 0.6)),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(Icons.arrow_downward,
                            size: 14, color: Color.fromRGBO(112, 12, 121, 0.6)),
                      ])
                ])),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        const Text('Please Wait...',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF700C79))),
                        const SizedBox(
                          height: 10,
                        ),
                        LoadingAnimationWidget.threeArchedCircle(
                          color: const Color.fromRGBO(112, 12, 121, 1),
                          size: 50,
                        ),
                      ])),
                )
              : Container()
        ]));
  }

  getEmployeeData(userId, {month = null, year = null}) async {
    setState(() {
      isLoading = true;
    });

    String apiLink = dotenv.env['API_LINK']!;
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, dynamic> postData = {
      "user_id": userId,
      "year": year == null ? selectedYear : year,
      "month": month == null
          ? (items.indexOf(selectedValue!) + 1).toString()
          : (items.indexOf(month) + 1).toString()
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${appState.accessToken}'
    };
    try {
      final response = await dio.post(
          '${apiLink}Cafe/wallet_transactions/details',
          data: postData,
          options: Options(headers: headers));
      setState(() {
        isLoading = false;
      });
      final data = jsonDecode(response.data);
      setState(() {
        transactions = data.reversed.toList();
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      appState.showTechnicalError(context);
    }
  }
}

class Employee {
  Employee(this.id, this.date, this.points);
  final int id;
  final String date;
  final int points;
}
