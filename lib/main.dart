import 'dart:async';
import 'dart:convert';
import 'package:flutter_ebay_search/Publication.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ebay_search/flutter_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new clsMain(),
  ));
}

final List<Publication> list_publication = new List<Publication>();

class PublicationItem extends StatelessWidget {
  PublicationItem({Key key, @required this.publication})
      : assert(publication != null && publication.isValid),
        super(key: key);
  static final height = 390.0;
  final Publication publication;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Container(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.all(10.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                    child: new Image.network(publication.photo,
                        fit: BoxFit.cover, height: 100.0, width: 100.0),
                    margin: new EdgeInsets.only(right: 10.0),
                  ),
                  new Expanded(
                    child: new Container(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            publication.title,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          new Text(
                            publication.price,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.green),
                          ),
                          new Text(publication.paymentMethod)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              child: new Text(publication.detail),
              margin: new EdgeInsets.all(10.0),
            ),

            new ButtonTheme.bar(
              child: new ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new FlatButton(
                    child: const Text('Detail'),
                    textColor: Colors.blue,
                    onPressed: () {
                      _launchURL(publication.url);
                      /* do nothing */
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

const jsonCodec = const JsonCodec();

class clsMain extends StatefulWidget {
  @override
  clsMainList createState() => new clsMainList();
}

class clsMainList extends State<clsMain> {
  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Flutter Ebay Search'),
        actions: [searchBar.getSearchAction(context)]);
  }

  Map data;

  Future<String> getData(String search) async {
    String MyAppID = "MyAppID";
    var url =
        "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=" +
            MyAppID +
            "&GLOBAL-ID=EBAY-US&RESPONSE-DATA-FORMAT=JSON&keywords=" +
            search +
            "&paginationInput.entriesPerPage=10&itemFilter(0).name=MaxPrice&itemFilter(0).value=25&itemFilter(0).paramName=Currency&itemFilter(0).paramValue=USD&itemFilter(1).name=FreeShippingOnly&itemFilter(1).value=true&itemFilter(2).name=ListingType&itemFilter(2).value(0)=AuctionWithBIN&itemFilter(2).value(1)=FixedPrice&itemFilter(2).value(2)=StoreInventory";
    var httpClient = createHttpClient();
    var response = await httpClient.get(url, headers: {
      "Accept": "application/json",
    });
    this.setState(() {
      data = JSON.decode(response.body);
    });
    list_publication.clear();
    List<Map> findItemsByKeywordsResponse =
        data["findItemsByKeywordsResponse"];
    List<Map> searchResult = findItemsByKeywordsResponse[0]["searchResult"];
    List<Map> items = searchResult[0]["item"];

    for (var i = 0; i < items.length; i++) {
      Map dat = items[i];
      List<String> title = dat["title"];
      List<String> photo = dat['galleryURL'];
      List<String> detail = dat['title'];
      List<Map> sellingStatus = dat['sellingStatus'];
      List<Map> currentPrice = sellingStatus[0]["currentPrice"];
      List<String> paymentMethod = dat['paymentMethod'];
      List<String> viewItemURL = dat['viewItemURL'];
      list_publication.add(new Publication(
          photo[0],
          title[0],
          detail[0],
          currentPrice[0]['__value__'] + " " + currentPrice[0]['@currencyId'],
          paymentMethod[0],
          viewItemURL[0]));
    }

    return "Success!";
  }

  void onSubmitted(String value) {
    this.getData(value);
  }

  clsMainList() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted);
  }

  @override
  void initState() {
    this.getData("MacBook");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new Drawer(
          child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: const Text('Victor Rances'),
            accountEmail: const Text('victordevcode@gmail.com'),
            currentAccountPicture: const CircleAvatar(
                backgroundImage: const AssetImage('img/perfil.jpg')),
            onDetailsPressed: () {},
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new ExactAssetImage('img/header.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.person),
            title: new Text('CodigoPanda'),
            onTap: () {},
          ),
          new Divider(),
          new ListTile(
            leading: const Icon(Icons.account_circle),
            title: new Text('About'),
            onTap: () {},
          ),
          new ListTile(
            leading: const Icon(Icons.settings_power),
            title: new Text('exit'),
            onTap: () {},
          ),
        ],
      )),
      appBar: searchBar.build(context),
      body: new RefreshIndicator(
        child: new ListView.builder(
            itemCount: list_publication == null ? 0 : list_publication.length,
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            itemBuilder: _itemBuilder),
        onRefresh: _onRefresh,
      ),
    );
  }

  Future<Null> _onRefresh() {
    Completer<Null> completer = new Completer<Null>();
    Timer timer = new Timer(new Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Publication todo = list_publication[index];
    return new PublicationItem(publication: todo);
  }
}
