import 'package:flutter/material.dart';
import '../style/colors.dart';
import 'object_list/post_model.dart';
import 'package:numberpicker/numberpicker.dart';
import 'chiamateServer/http_service.dart';
import 'dart:math';
import 'screen/specs.dart';

class MyDispensa extends StatefulWidget {
  MyDispensa({Key key}) : super(key: key);

  @override
  _MyDispensaState createState() => _MyDispensaState();
}




class _MyDispensaState extends State<MyDispensa> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('my Items',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Text('just food',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }
            return PostsPage();
          }),
    );




  }
  /*Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: ListView.builder(
          
          //?crea una lista scrollable di widget
          itemCount: list.length,
          itemBuilder: (context, index) => _itemBuilder(context, list[index],
              Colori.primarioTenue, index), //?richiamo di funzione anonima
        ),
      ),
    );
  }*/

  /*_onLocationTap(BuildContext context, int locationID) {
    Navigator.pushNamed(context, LocationDetailRoute,
        arguments: {"id": locationID});
  }*/

  
}




class PostsPage extends StatelessWidget {
  final HttpService httpService = HttpService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: httpService.getPosts(),
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          if (snapshot.hasData) {
            List<Post> posts = snapshot.data;
            return ListView(
              children: posts
                  .map(
                    (Post post) => _itemBuilder(post),
                  )
                  .toList(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    
  }

    Widget _itemBuilder(Post post) {
    return GestureDetector(
        child: Container(
          child: Stack(
            //alignment: AlignmentDirectional.bottomEnd,
            children: [
              TileOverlay(post),
            ],
          ),
        ),
        /*onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Specs(location)),
          );
        }*/);
  }
}











class TileOverlay extends StatelessWidget {

  final Post post;
  TileOverlay(this.post);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
              //padding: EdgeInsets.symmetric(vertical: 5.0),
              /*decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5)), //opacità tra 0 e 1*/
              child: PostTile(post:post)),
        )
      ],
    );
  }
}

class PostTile extends StatefulWidget {
  PostTile({this.post});

  final Post post;
  @override
  _PostTileState createState() =>
      new _PostTileState(post:post);
}

//----------------------------------------------------------------------------------------//

class _PostTileState extends State<PostTile> {
  _PostTileState({this.post,}); //!default value, parametri tra {} vuol dire che sono opzionali
  final Post post;


  @override
  Widget build(BuildContext context) {
    //costruzione item dove inserire il NOME del prodotto
    final nameItem = Container(
      width: 150,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 12.0),
      child: Text(
        post.name.toUpperCase(),
        //style: Theme.of(context).textTheme.bodyText1,
        style: TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.fade,
        //textAlign: TextAlign.justify,
      ),
    );

    final numberPicker = NumberPicker(
      textStyle: TextStyle(fontSize: 12),
      value: post.qta,
      minValue: 0,
      maxValue: 100,
      step: 1,
      itemHeight: 50,
      itemWidth: 50,
      axis: Axis.horizontal,
      onChanged: (value) => setState(() => post.qta = value),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
    );


    final trash = IconButton(
      alignment: Alignment.centerRight,
      icon: Icon(Icons.delete),
      color: Colori.scuro,
      iconSize: 35,
    );

    return Column(
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          margin: const EdgeInsets.only(left: 6.0, right: 6.0),
          decoration: BoxDecoration(
            color: Colori.primarioTenue,
            borderRadius: BorderRadius.circular(10),
            //border: Border.all(color: Colors.black26),
          ),
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //SizedBox(height: 16)

                    nameItem,
                    

                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //mainAxisAlignment: MainAxisAlignment.value(),
                        children: [
                          numberPicker,
                          trash,
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
        ),
        //Divider(color: Colors.grey, height: 32),
      ],
    );
  }
}