import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

import 'package:share/share.dart';
import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offSet = 0;

 Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=iYTDGOjoejlZHS2Cxoai2TpeSfpqXxtg&limit=20&rating=g");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=iYTDGOjoejlZHS2Cxoai2TpeSfpqXxtg&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en");

        return json.decode(response.body);
  }

  @override
  void initState(){
   super.initState();

   _getGifs().then((map){
     print(map);
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // appbar é a barra encima do app
        backgroundColor: Colors.black, // deixa o fundo do app preto
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"), // titulo que vai aparecer na appbar
        centerTitle: true, // deixando o titulo centralizado
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
         Padding(
           padding: EdgeInsets.all(10.0),
           child:  TextField(
             decoration: InputDecoration(
                 labelText: "Search Here!",
                 labelStyle: TextStyle(color: Colors.white),
                 border: OutlineInputBorder()
             ),
             style: TextStyle(color: Colors.white, fontSize: 18.0),
             textAlign: TextAlign.center,
             onSubmitted: (text) {
               setState(() {
                 _search = text;
                 _offSet = 0;
               });
             }, // essa função é chamado, quando pego o texto digitado e aperto no botão
           ),
         ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if(snapshot.hasError) return Container();
                      else return _createGifTable(context, snapshot);
                  }
                }
            ),
          ),
        ],
      )
    );
  }

  int _getCount(List data) {
    if(_search == null || _search.isEmpty) // se a pesquisa for nula ou vazia, retorna
    {
      return data.length;
    } else {
      return data.length +1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
      return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // mostrar a grid na tela, (o formato)
            crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if(_search == null || index < snapshot.data["data"].length) // se eu não estiver pesquisando, vou retornar meu gif:
          return GestureDetector( // se eu não estiver pesquisando, e não for meu último item, vou retornar meu gif:
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(context, // navigator.push faz com que eu vá para outra tela, usando o MaterialPageRoute
              MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
              );
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
            );
          else // se for o meu icone, retorno para carregar mais
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // alinhamento no eixo principal
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Loading more ...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),)
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offSet += 19;
                  });
                },
              ),
            );
        }
      );
  }
}
