class MonsterAbilityDeckModel {
  MonsterAbilityDeckModel(this.name, this.edition, this.cards);

  final String name;
  final String edition;
  final List<MonsterAbilityCardModel> cards; //need to interpret strings later on

  factory MonsterAbilityDeckModel.fromJson(Map<String, dynamic> data, String edition) {
    final name = data['name'] as String;
    //final edition = data['edition'] as String;
    final  List<dynamic> dynamicCards = data['cards'] as List<dynamic>;
    List<MonsterAbilityCardModel> cards = [];
    for (var card in dynamicCards) {
      //["Nothing special", 384, false, 50, "%move% + 0","*.........", "%attack% + 0" ],
      String title = name;
      if(card[0] is String) {
        title = card[0] as String;
        card.removeAt(0);
      }
      int nr = card[0] as int;
      bool shuffle = card[1] as bool;
      int initiative = card[2] as int;
      List<GraphicPositional> graphicPositionals = [];
      if(card[3] is List) {
        //handle the graphic extras
        List<dynamic> list = card[3];

        for (var item in list) {
          double angle =0;
          double scale = 1;
          if(item.containsKey('angle')) {
            angle = item['angle'];
          }
          if(item.containsKey('scale')) {
            scale = item['scale'];
          }
          GraphicPositional pos = GraphicPositional(item["gfx"], item["x"], item["y"],scale, angle);
          graphicPositionals.add(pos);
        }

        card.removeAt(3);
      }
      List<String> lines = [];
      for (int i = 3; i < card.length; i++) {
        lines.add(card[i] as String);
      }
      cards.add(MonsterAbilityCardModel(title, nr, shuffle, initiative, lines, name, graphicPositionals));
    }
    return MonsterAbilityDeckModel(name, edition, cards);
  }
}

class GraphicPositional {
  GraphicPositional(this.gfx, this.x, this.y, this.scale, this.angle);
  final String gfx;
  final double x;
  final double y;
  final double scale;
  final double angle;
}

class MonsterAbilityCardModel {
  MonsterAbilityCardModel(this.title, this.nr, this.shuffle, this.initiative, this.lines, this.deck, this.graphicPositional);
  final String deck;
  final String title;
  final int nr;
  final bool shuffle;
  final int initiative; //or String
  final List<String> lines;
  final List<GraphicPositional> graphicPositional;

  @override
  String toString() {
    return '{'
        '"nr": $nr, '
        '"deck": "$deck" '
        '}';
  }
}
