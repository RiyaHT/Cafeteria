import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'custom_provider.dart';
import 'dio_singleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final CarouselController carouselController = CarouselController();
  String buttonText = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime selectedDate = DateTime.now();
  late final TabController _tabController;
  int currentIndex = 0;
  var menuItems = {'breakfast': [], 'lunch': [], 'snacks': []};
  List<String> Tabs = ['Breakfast', 'Lunch', 'Snacks'];
  User user = User(0, '');
  List<Breakfast> breakfastItems = <Breakfast>[];
  List<Lunch> lunch = <Lunch>[];
  List<Snacks> snacks = <Snacks>[];
  String? selectedValue = 'Thane Hub 1';
  String apiLink = dotenv.env['API_LINK']!;
  int currentPageIndex = 0;
  bool isFetching = false;
  Dio dio = DioSingleton.dio;
  late Timer _timer;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;
  var items = [
    'Thane Hub 1',
    'Thane Hub 2',
    'HO',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getUserBalance();
    _startTimer();
    Future.delayed(Duration.zero, () => {getAllItems(selectedValue)});
  }

  void _startTimer() {
    print("timer started");
    const duration = Duration(seconds: 300);
    _timer = Timer(duration, _redirectToLogin);
  }

  void _redirectToLogin() {
    print("redirected");
    Navigator.pushReplacementNamed(context, '/login');
  }

  getUserBalance() async {
    _prefs.then((SharedPreferences prefs) async {
      setState(() {
        isFetching = true;
      });
      String apiLink = dotenv.env['API_LINK']!;
      final appState = Provider.of<AppState>(context, listen: false);
      Map<String, dynamic> postData = {
        'user_Id': prefs.getInt("puserId").toString(),
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/json",
        "Authorization": 'Bearer ${appState.accessToken}'
      };

      try {
        final response = await dio.post('${apiLink}Cafe/getUserBalance',
            data: postData, options: Options(headers: headers));
        final Map<String, dynamic> data = jsonDecode(response.data);
        if (response.statusCode == 200) {
          setState(() {
            user.balance = data["Balance Amount"];
            isFetching = false;
          });
          appState.updateBalance(data["Balance Amount"]);
        }
      } catch (error) {
        setState(() {
          isFetching = false;
        });
        appState.showTechnicalError(context);
      }
    });
  }

  getAllItems(location) async {
    var formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final appState = Provider.of<AppState>(context, listen: false);
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      "Accept": "application/json",
      "Authorization": 'Bearer ${appState.accessToken}'
    };
    for (var item in Tabs) {
      final response = await dio.get(
          '${apiLink}Cafe/api/menu/category/${item}/date/${formattedDate}/location/${location}',
          options: Options(headers: headers));

      var data = jsonDecode(response.data);
      if (response.statusCode == 200) {
        setState(() {
          menuItems[item.toLowerCase()] = data;
        });
      } else {
        throw Exception('Failed to create album.');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Container(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              "assets/images/logo.JPG",
              fit: BoxFit.cover,
            ),
          ),
          leadingWidth: 140,
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert,
                    color: Color.fromRGBO(112, 12, 121, 1)),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                        value: 0,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                buttonText = '₹ ${user.balance} ';
                              });
                              Future.delayed(const Duration(milliseconds: 5000),
                                  () {
                                setState(() {
                                  buttonText = '';
                                });
                              });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Color(0xFF700C79),
                                  ),
                                  Text(
                                      buttonText == ''
                                          ? '  Check Balance'
                                          : '  Available: ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF700C79))),
                                  isFetching
                                      ? LoadingAnimationWidget
                                          .threeArchedCircle(
                                          color: const Color.fromRGBO(
                                              112, 12, 121, 1),
                                          size: 15,
                                        )
                                      : Text(buttonText,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF700C79)))
                                ]),
                          );
                        })),
                    PopupMenuItem<int>(
                        value: 1,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Color(0xFF700C79),
                                ),
                                Text('  My Profile',
                                    style: TextStyle(
                                        fontSize: 15,
                                        // letterSpacing: 3,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF700C79)))
                              ]),
                        )),
                    PopupMenuItem<int>(
                        value: 2,
                        child: TextButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color(0xFF700C79),
                                ),
                                Text('  Log Out',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF700C79)))
                              ]),
                        )),
                  ];
                })
          ]),
      body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white12,
                Color.fromRGBO(112, 12, 121, 0.55),
                Color.fromRGBO(63, 166, 235, 0.55),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: InkWell(
                  onTap: () {
                    print(currentIndex);
                  },
                  child: CarouselSlider(
                      items: [
                        Container(
                          height: 15,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/images/breakfast_2.JPG"),
                                  fit: BoxFit.fill)),
                        ),
                        Container(
                          height: 15,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                  image:
                                      AssetImage("assets/images/lunch_2.JPG"),
                                  fit: BoxFit.fill)),
                        ),
                        Container(
                          height: 15,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                  image:
                                      AssetImage("assets/images/snacks_2.JPG"),
                                  fit: BoxFit.fill)),
                        )
                      ],
                      carouselController: carouselController,
                      options: CarouselOptions(
                        scrollPhysics: const BouncingScrollPhysics(),
                        autoPlay: true,
                        aspectRatio: 2.5,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      )),
                ),
              ),
              Container(
                  margin: const EdgeInsets.all(18),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color:
                            //  Color.fromRGBO(231, 181, 229, 0.9),
                            Color.fromRGBO(42, 4, 49, 0.4),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Change Location: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(112, 12, 121, 1),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Row(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                isExpanded: true,
                                hint: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Select Location',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                items: items
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
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
                                  });
                                  getAllItems(selectedValue);
                                },
                                buttonStyleData: ButtonStyleData(
                                  width: 150,
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
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TabBar(
                      labelColor: const Color.fromRGBO(112, 12, 121, 1),
                      labelPadding: const EdgeInsets.all(3),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color.fromRGBO(112, 12, 121, 0.7),
                      controller: _tabController,
                      tabs: Tabs.map((e) => Text(e)).toList(),
                    ),
                    Container(
                      height: 280,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: menuItems['breakfast']!.length,
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
                                        height: 3,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Colors.purple,
                                              radius: 15,
                                              child: CircleAvatar(
                                                radius: 13,
                                                backgroundColor: Colors.white,
                                                backgroundImage: AssetImage(
                                                  ("assets/images/breakfast_2.JPG"),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      ' ${menuItems['breakfast']![index]['menu']} ',
                                                      softWrap: false,
                                                      maxLines: 6,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              112, 12, 121, 1)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '  ₹ ${menuItems['breakfast']![index]['price']} ',
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      112, 12, 121, 1)),
                                            ),
                                          ]),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ]));
                              }),
                          ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: menuItems['lunch']!.length,
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
                                        height: 3,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Colors.purple,
                                              radius: 15,
                                              child: CircleAvatar(
                                                radius: 13,
                                                backgroundColor: Colors.white,
                                                backgroundImage: AssetImage(
                                                  ("assets/images/lunch_2.JPG"),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      ' ${menuItems['lunch']![index]['menu']}  ',
                                                      softWrap: false,
                                                      maxLines: 6,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              112, 12, 121, 1)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '  ₹ ${menuItems['lunch']![index]['price']}  ',
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      112, 12, 121, 1)),
                                            ),
                                          ]),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ]));
                              }),
                          ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: menuItems['snacks']!.length,
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
                                        height: 3,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: Colors.purple,
                                              radius: 15,
                                              child: CircleAvatar(
                                                radius: 13,
                                                backgroundColor: Colors.white,
                                                backgroundImage: AssetImage(
                                                  ("assets/images/snacks_2.JPG"),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      ' ${menuItems['snacks']![index]['menu']}  ',
                                                      softWrap: false,
                                                      maxLines: 6,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              112, 12, 121, 1)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '  ₹ ${menuItems['snacks']![index]['price']}  ',
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      112, 12, 121, 1)),
                                            ),
                                          ]),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                    ]));
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scroll for more options ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(112, 12, 121, 0.6)),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Icon(Icons.arrow_downward,
                              size: 14,
                              color: Color.fromRGBO(112, 12, 121, 0.6)),
                        ])
                  ])),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: Colors.purple),
                              onPressed: () {
                                if (user.balance == 0) {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      elevation: 10,
                                      shadowColor: Colors.purple,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      content: const Text(
                                        'Balance Unavailable',
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 112, 12, 121),
                                            elevation: 0, // Elevation
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.pushNamed(context, '/scanner');
                                }
                              },
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(112, 12, 121, 1),
                                      Color.fromARGB(255, 32, 35, 202)
                                    ],
                                  ).createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.qr_code_scanner_outlined,
                                  size: 40,
                                ),
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'Scan QR Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 12, 121, 1),
                            ),
                          )
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                                backgroundColor: Colors.white,
                                elevation: 10,
                                shadowColor: Colors.purple,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/history');
                              },
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(112, 12, 121, 1),
                                      Color.fromARGB(255, 32, 35, 202)
                                    ],
                                  ).createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.aod_outlined,
                                  size: 40,
                                ),
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'Payment History',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(112, 12, 121, 1),
                            ),
                          )
                        ]),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          )),
    );
  }
}

class Breakfast {
  Breakfast(this.menu, this.price);
  final String menu;
  final int price;
}

class Lunch {
  Lunch(this.menu, this.price);
  final String menu;
  final int price;
}

class Snacks {
  Snacks(this.menu, this.price);
  final String menu;
  final int price;
}

class User {
  User(
    this.balance,
    this.date,
  );
  int balance;
  final String date;
}
