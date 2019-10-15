class PokemonModel {
  final int id;
  final String name;
  final String sprite;
  final List<String> types;

  PokemonModel({
    this.id,
    this.name,
    this.types,
    this.sprite,
  });

  PokemonModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        sprite = map['sprites']['front_default'],
        types = map['types']
            .map<String>((t) => t['type']['name'] as String)
            .toList();

  static List<PokemonModel> fromMapList(List<dynamic> list) =>
      list.map((p) => PokemonModel.fromMap(p)).toList();
}
