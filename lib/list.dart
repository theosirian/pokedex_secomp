import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import './state.dart';
import './model.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonListScreen> {
  bool search;
  TextEditingController searchController;

  Dio dio;
  LoadState loadState;

  @override
  void initState() {
    super.initState();

    this.dio = Dio();
    this.dio.options.baseUrl = 'https://pokeapi.co/api/v2';

    this.loadState = InitialState();

    this.search = false;
    this.searchController = TextEditingController();
    this.searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    this.searchController.dispose();
    super.dispose();
  }

  void handleError(DioError e) {
    switch (e.type) {
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        setState(() {
          this.loadState = FailureState(
            error: 'O servidor demorou demais para responder.',
          );
        });
        break;

      case DioErrorType.RESPONSE:
        switch (e.response.statusCode) {
          case 400:
            setState(() {
              this.loadState = FailureState(
                error: 'A requisição não pode ser completada.',
              );
            });
            break;

          case 401:
            setState(() {
              this.loadState = FailureState(
                error: 'É necessário autenticação para completar a requisição.',
              );
            });
            break;

          case 403:
            setState(() {
              this.loadState = FailureState(
                error: 'Você não está autorizada a acessar esse recurso.',
              );
            });
            break;

          case 404:
            setState(() {
              this.loadState = FailureState(
                error: 'O recurso requisitado não existe.',
              );
            });
            break;

          case 429:
            setState(() {
              this.loadState = FailureState(
                error: 'Você ultrapassou o limite de requisições.',
              );
            });
            break;
          case 500:
            setState(() {
              this.loadState = FailureState(
                error:
                    'Ocorreu um erro no servidor, por favor tente novamente mais tarde.',
              );
            });
            break;

          default:
            setState(() {
              this.loadState = FailureState(
                error: 'Ocorreu um erro, por favor tente novamente mais tarde.',
              );
            });
        }
        break;

      default:
        setState(() {
          this.loadState = FailureState(
            error: 'Ocorreu um erro, por favor tente novamente mais tarde.',
          );
        });
    }
  }

  Future<PokemonModel> loadItem(String name) async {
    try {
      final response = await this.dio.get('/pokemon/$name');
      return PokemonModel.fromMap(response.data);
    } on DioError catch (e) {
      this.handleError(e);
    }
  }

  void loadData() async {
    setState(() {
      this.loadState = LoadingState();
    });

    try {
      final response = await this.dio.get('/pokemon/?limit=10');

      List<PokemonModel> data = await Future.wait(
        response.data['results'].map<Future<PokemonModel>>(
          (p) => this.loadItem(p['name']),
        ),
      );

      setState(() {
        this.loadState = SuccessState(
          data: data,
        );
      });
    } on DioError catch (e) {
      this.handleError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.loadState is InitialState) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TitleWidget('Bem-vindo ao mundo Pokémon!'),
              SubtitleWidget('Clique para começar sua jornada'),
              const SizedBox(height: 24.0),
              ButtonWidget(
                text: 'COMEÇAR',
                color: Colors.red,
                textColor: Colors.white,
                onPressed: this.loadData,
              ),
            ],
          ),
        ),
      );
    }

    if (this.loadState is LoadingState) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitleWidget('Bem-vindo ao mundo Pokémon!'),
              SubtitleWidget('Sua jornada começará em breve...'),
              const SizedBox(height: 24.0),
              ButtonWidget(
                text: 'CARREGANDO',
                color: Colors.red,
                textColor: Colors.white,
                onPressed: null,
              ),
            ],
          ),
        ),
      );
    }

    if (this.loadState is FailureState) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitleWidget('Bem-vindo ao mundo Pokémon!'),
              SubtitleWidget((this.loadState as FailureState).error),
              const SizedBox(height: 24.0),
              ButtonWidget(
                text: 'TENTAR NOVAMENTE',
                color: Colors.red,
                textColor: Colors.white,
                onPressed: this.loadData,
              ),
            ],
          ),
        ),
      );
    }

    final imageSize = 0.25 * MediaQuery.of(context).size.width;

    final floatingActionButton = this.search
        ? null
        : FloatingActionButton(
            onPressed: () => setState(() {
              this.search = true;
            }),
            child: Icon(Icons.search),
            backgroundColor: Colors.red,
          );

    final appBar = this.search
        ? AppBar(
            leading: Icon(Icons.search),
            title: TextField(
              autofocus: true,
              controller: this.searchController,
              cursorColor: Colors.white,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
                hintText: 'Procurar por nome ou número',
                hintStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.white,
                onPressed: () => setState(() {
                  this.search = false;
                }),
              )
            ],
          )
        : AppBar(
            title: Text(
              'Pokédex',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          );
    final data = (this.loadState as SuccessState).data;

    final searchText = this.searchController.text.trim().toLowerCase();

    final pokemons = this.search
        ? data.where(
            (pokemon) =>
                pokemon.id.toString().contains(searchText) ||
                pokemon.name.contains(searchText),
          )
        : data;

    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pokemons.map((pokemon) {
              final typesWidget = pokemon.types.length > 1
                  ? Row(
                      children: <Widget>[
                        Expanded(child: TypeWidget.left(pokemon.types[0])),
                        Expanded(child: TypeWidget.right(pokemon.types[1])),
                      ],
                    )
                  : TypeWidget.center(pokemon.types[0]);

              return Container(
                color: pokemon.id % 2 == 0 ? Colors.white12 : Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: IntrinsicHeight(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: CachedNetworkImage(
                          imageUrl: pokemon.sprite,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error)),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '${pokemon.id.toString().padLeft(3, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  pokemon.name.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: typesWidget,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  final String text;

  TitleWidget(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 16.0,
        ),
        child: Text(
          this.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
      );
}

class SubtitleWidget extends StatelessWidget {
  final String text;

  SubtitleWidget(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 8.0,
        ),
        child: Text(
          this.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      );
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final void Function() onPressed;

  ButtonWidget({
    this.text,
    this.color,
    this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        child: FlatButton(
          child: Text(this.text),
          color: this.color,
          textColor: this.textColor,
          onPressed: this.onPressed,
        ),
      );
}

class TypeWidget extends StatelessWidget {
  final String text;
  final bool left;
  final bool right;

  TypeWidget.left(
    this.text,
  )   : left = true,
        right = false;

  TypeWidget.right(
    this.text,
  )   : left = false,
        right = true;

  TypeWidget.center(
    this.text,
  )   : left = true,
        right = true;

  Color color() {
    switch (this.text) {
      case 'bug':
        return Color(0xffA6B91A);
      case 'dark':
        return Color(0xff705746);
      case 'dragon':
        return Color(0xff6F35FC);
      case 'electric':
        return Color(0xffF7D02C);
      case 'fairy':
        return Color(0xffD685AD);
      case 'fighting':
        return Color(0xffC22E28);
      case 'fire':
        return Color(0xffEE8130);
      case 'flying':
        return Color(0xffA98FF3);
      case 'ghost':
        return Color(0xff735797);
      case 'grass':
        return Color(0xff7AC74C);
      case 'ground':
        return Color(0xffE2BF65);
      case 'ice':
        return Color(0xff96D9D6);
      case 'normal':
        return Color(0xffA8A77A);
      case 'poison':
        return Color(0xffA33EA1);
      case 'psychic':
        return Color(0xffF95587);
      case 'rock':
        return Color(0xffB6A136);
      case 'shadow':
        return Color(0xff000000);
      case 'steel':
        return Color(0xffB7B7CE);
      case 'unknown':
        return Color(0xff000000);
      case 'water':
        return Color(0xff6390F0);

      default:
        return Colors.black;
    }
  }

  Color textColor() {
    switch (this.text) {
      case 'bug':
      case 'dark':
      case 'dragon':
      case 'fairy':
      case 'fighting':
      case 'fire':
      case 'flying':
      case 'ghost':
      case 'grass':
      case 'poison':
      case 'psychic':
      case 'rock':
      case 'shadow':
      case 'steel':
      case 'unknown':
      case 'water':
        return Colors.white70;

      case 'electric':
      case 'ground':
      case 'ice':
      case 'normal':
        return Colors.black54;

      default:
        return Colors.red;
    }
  }

  final borderRadius = Radius.circular(16.0);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: this.color(),
          borderRadius: BorderRadius.only(
            topRight: this.right ? this.borderRadius : Radius.zero,
            bottomRight: this.right ? this.borderRadius : Radius.zero,
            topLeft: this.left ? this.borderRadius : Radius.zero,
            bottomLeft: this.left ? this.borderRadius : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            this.text.toUpperCase(),
            style: TextStyle(
              color: this.textColor(),
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
