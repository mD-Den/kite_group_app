import 'dart:developer';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kite_group_app/data/local_data_store/local_data_store.dart';
import 'package:kite_group_app/ui/pages/pages.dart';

import '../../config/constants.dart';
import '../../data/models/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  static const String id = 'ProductsPage';

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  late List<Product> _allProducts;
  late List<Product> _filteredProducts;

  final LocalDataStore _store = LocalDataStore();

  final TextEditingController _searchController = TextEditingController();

  late FirebaseMessaging messaging;

  bool needLoading = false;
  String numberScreen = 'Second Screen';

  @override
  void initState() {
    super.initState();
    _allProducts = [
      Product(name: 'Jacket', category: 'Category A', price: 10.0),
      Product(name: 'Boots', category: 'Category B', price: 20.0),
      Product(name: 'T-shirt', category: 'Category A', price: 30.0),
    ];

    _filteredProducts = List.from(_allProducts);

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {});

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _store.setUrl(website_2);
      log('Message clicked!');
      AppMetrica.reportEventWithJson('Route', "{\"route\":\"web_view\"}");
      Navigator.of(context).pushNamed(WebViewPage.id);
    });
  }

  Future<void> fakeNextScreen() async {
    needLoading = true;
    if (numberScreen == 'Second Screen') {
      setState(() {
        _allProducts = [
          Product(name: 'Куртка', category: 'Категория A', price: 10.0),
          Product(name: 'Кроссы', category: 'Категория B', price: 20.0),
          Product(name: 'Футболка', category: 'Категория A', price: 30.0),
        ];
        numberScreen = 'Первый экран';
        _filteredProducts = List.from(_allProducts);
      });
    } else {
      setState(() {
        numberScreen = 'Second Screen';
        _allProducts = [
          Product(name: 'Jacket', category: 'Category A', price: 10.0),
          Product(name: 'Boots', category: 'Category B', price: 20.0),
          Product(name: 'T-shirt', category: 'Category A', price: 30.0),
        ];
        _filteredProducts = List.from(_allProducts);
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        needLoading = false;
      });
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredProducts = _allProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredProducts = List.from(_allProducts);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: needLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterProducts,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Column(
                          children: [
                            ElevatedButton(
                              style: const ButtonStyle(
                                  animationDuration: Duration(seconds: 1),
                                  padding: MaterialStatePropertyAll<
                                      EdgeInsetsGeometry>(EdgeInsets.all(10))),
                              onPressed: () {
                                switch (index) {
                                  case 0:
                                    _store.setUrl(website_0);
                                    break;
                                  case 1:
                                    _store.setUrl(website_1);
                                    break;
                                  case 2:
                                    _store.setUrl(website_2);
                                }
                                AppMetrica.reportEventWithJson('Route',
                                    "{\"route\":\"web_view\", \"number\":\"$index\"}");
                                Navigator.of(context).pushNamed(
                                  WebViewPage.id,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.name,
                                    ),
                                    Text(
                                        '${product.category} - \$${product.price}'),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => fakeNextScreen(),
                  child: Text(numberScreen),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
    );
  }
}
