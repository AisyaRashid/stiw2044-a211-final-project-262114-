import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:panebakery/modul/config.dart';
import 'package:panebakery/modul/product.dart';
import 'package:panebakery/modul/user.dart';
import 'package:panebakery/view/productdetail.dart';

class TabPage1 extends StatefulWidget {
  final User user;
  const TabPage1({Key? key, required this.user}) : super(key: key);

  @override
  State<TabPage1> createState() => _TabPage1State();
}

class _TabPage1State extends State<TabPage1> {
  List productlist = [];
  String titlecenter = "Loading data...";
  late double screenHeight, screenWidth, resWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late ScrollController _scrollController;
  int scrollcount = 10;
  int rowcount = 2;
  int numprd = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadBuyerProducts();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowcount = 3;
    }

    return Scaffold(
        body: productlist.isEmpty
            ? Center(
                child: Text(titlecenter,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)))
            : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text("Products Available",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Text(numprd.toString() + " found"),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: rowcount,
                      controller: _scrollController,
                      children: List.generate(scrollcount, (index) {
                        return Card(
                            child: InkWell(
                          onTap: () => {_prodDetails(index)},
                          child: Column(
                            children: [
                              Flexible(
                                flex: 6,
                                child: CachedNetworkImage(
                                  width: screenWidth,
                                  fit: BoxFit.cover,
                                  imageUrl: MyConfig.server +
                                      "/images/products/" +
                                      productlist[index]['prid'] +
                                      ".png",
                                  placeholder: (context, url) =>
                                      const LinearProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Flexible(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                            truncateString(productlist[index]
                                                    ['prname']
                                                .toString()),
                                            style: TextStyle(
                                                fontSize: resWidth * 0.045,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "RM " +
                                                double.parse(productlist[index]
                                                        ['prprice'])
                                                    .toStringAsFixed(2) +
                                                "  -  " +
                                                productlist[index]['prqty'] +
                                                " in stock",
                                            style: TextStyle(
                                              fontSize: resWidth * 0.03,
                                            )),
                                        Text(
                                            df.format(DateTime.parse(
                                                productlist[index]['prdate'])),
                                            style: TextStyle(
                                              fontSize: resWidth * 0.03,
                                            ))
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ));
                      }),
                    ),
                  ),
                ],
              ),
        // floatingActionButton: SpeedDial(
        //   animatedIcon: AnimatedIcons.menu_close,
        //   children: [
        //     SpeedDialChild(
        //         child: const Icon(Icons.add),
        //         label: "New Product",
        //         labelStyle: const TextStyle(color: Colors.black),
        //         labelBackgroundColor: Colors.white,
        //         onTap: null),
        //   ],
        // )
        );
  }

  void _loadBuyerProducts() {
    http.post(Uri.parse(MyConfig.server + "/php/loadbuyer_products.php"),
        body: {}).then((response) {
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        // ignore: avoid_print
        print(response.body);
        var extractdata = data['data'];
        setState(() {
          productlist = extractdata["products"];
          numprd = productlist.length;
          if (scrollcount >= productlist.length) {
            scrollcount = productlist.length;
          }
        });
      } else {
        setState(() {
          titlecenter = "No Data";
        });
      }
    });
  }

  String truncateString(String str) {
    if (str.length > 15) {
      str = str.substring(0, 15);
      return str + "...";
    } else {
      return str;
    }
  }

  _prodDetails(int index) {
    Product product = Product(
        prid: productlist[index]['prid'],
        prname: productlist[index]['prname'],
        prdesc: productlist[index]['prdesc'],
        prprice: productlist[index]['prprice'],
        prqty: productlist[index]['prqty'],
        prdel: productlist[index]['prdel'],
        prstate: productlist[index]['prstate'],
        prloc: productlist[index]['prloc'],
        prlat: productlist[index]['prlat'],
        prlong: productlist[index]['prlong'],
        prdate: productlist[index]['prdate'],
        pridowner: productlist[index]['pridowner'],
        user_email: productlist[index]['user_email'],
        user_name: productlist[index]['user_name'],
        user_phone: productlist[index]['user_phone'],);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ProductDetailsPage(
                  product: product,
                )));
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        if (productlist.length > scrollcount) {
          scrollcount = scrollcount + 10;
          if (scrollcount >= productlist.length) {
            scrollcount = productlist.length;
          }
        }
      });
    }
  }
}