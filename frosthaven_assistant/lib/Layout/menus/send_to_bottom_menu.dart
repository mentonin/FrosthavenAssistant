import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/reorder_modifier_list_command.dart';
import '../../Resource/game_state.dart';
import '../../Resource/settings.dart';
import '../../services/service_locator.dart';

class SendToBottomMenu extends StatefulWidget {
  final int currentIndex;
  final int length;

  const SendToBottomMenu({
    Key? key,
    required this.currentIndex, required this.length,
  }) : super(key: key);

  @override
  SendToBottomMenuState createState() => SendToBottomMenuState();
}

class SendToBottomMenuState extends State<SendToBottomMenu> {
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 140,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: AssetImage(getIt<Settings>().darkMode.value
                ? 'assets/images/bg/dark_bg.png'
                : 'assets/images/bg/white_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () {
                int oldIndex = widget.length-1 - widget.currentIndex;
                int newIndex = widget.length-1;
                _gameState.action(ReorderModifierListCommand(0, oldIndex));
                Navigator.pop(context);
              },
              child:
              const Text("Send to Bottom", style: TextStyle(fontSize: 20))),
        ]));
  }
}
