import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Resource/commands/change_stat_commands/change_health_command.dart';

import '../Resource/action_handler.dart';
import '../Resource/commands/next_turn_command.dart';
import '../Resource/enums.dart';
import '../Resource/game_methods.dart';
import '../Resource/game_state.dart';
import '../Resource/scaling.dart';
import '../Resource/settings.dart';
import '../Resource/ui_utils.dart';
import '../services/service_locator.dart';

class ConditionIcon extends StatefulWidget {
  ConditionIcon(this.condition, this.size, this.owner, this.figure,
      {super.key}) {
    String suffix = "";
    if (GameMethods.isFrosthavenStyle(null)) {
      suffix = "_fh";
    }
    String imagePath = "assets/images/abilities/${condition.name}.png";
    if (suffix.isNotEmpty && hasGHVersion(condition.name)) {
      imagePath = "assets/images/abilities/${condition.name}$suffix.png";
    }
    gfx = imagePath;
  }

  final Condition condition;
  final double size;
  final ListItemData owner;
  final Figure figure;
  late final String gfx;

  @override
  ConditionIconState createState() => ConditionIconState();
}

class ConditionIconState extends State<ConditionIcon> {
  final animate = ValueNotifier<bool>(
      false); //this needs to exist outside of this class to apply when parent rebuilds. FUUUUUUUUUUUUUUUUUUUCCCKKK!!!!!

  //bool noMoreThisTurn = false;

  @override
  void dispose() {
    getIt<GameState>().commandIndex.removeListener(_animateListener);
    super.dispose();
  }

  @override
  void initState() {
    GameState gameState = getIt<GameState>();
    gameState.commandIndex.addListener(_animateListener);
    super.initState();
  }

  void _runAnimation() {
    animate.value = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      animate.value = false;
    });
  }

  void _animateListener() {
    GameState gameState = getIt<GameState>();
    Command? command;
    //TODO: does not work at all when networked.
    if (gameState.commandIndex.value >= 0 && gameState.commands.isNotEmpty) {
      command = gameState.commands[gameState.commandIndex.value];
    }
    if (command is TurnDoneCommand) {
      if (widget.owner.turnState == TurnsState.current) {
        //this turn started! play animation for wound and regenerate
        if (widget.condition == Condition.regenerate ||
            widget.condition == Condition.wound ||
            widget.condition == Condition.wound2) {
          _runAnimation();
        }
      }
      if (widget.owner.turnState == TurnsState.done &&
          gameState.currentList[command.index].id == widget.owner.id) {
        //was current last round but is no more
        if (widget.figure.conditionsAddedPreviousTurn.value
            .contains(widget.condition)) {
          if (widget.condition == Condition.bane) {
            _runAnimation();
          }
          //only run these if not automatically taken off. TODO: maybe run animations before removing is good?
          if (getIt<Settings>().expireConditions.value == false) {
            if (widget.condition == Condition.chill ||
                widget.condition == Condition.stun ||
                widget.condition == Condition.disarm ||
                widget.condition == Condition.immobilize ||
                widget.condition == Condition.invisible ||
                widget.condition == Condition.strengthen ||
                widget.condition == Condition.muddle ||
                widget.condition == Condition.impair) {
              _runAnimation();
            }
          }
        }
      }
    } else if (command is ChangeHealthCommand) {
      if (widget.figure ==
          GameMethods.getFigure(command.ownerId, command.figureId)) {
        if (command.change == -1) {
          if (widget.condition.name.contains("poison") ||
              widget.condition == Condition.regenerate ||
              widget.condition == Condition.ward ||
              widget.condition == Condition.brittle) {
            _runAnimation();
          }
        } else if (command.change == 1) {
          if (widget.condition == Condition.rupture ||
              widget.condition == Condition.wound ||
              widget.condition == Condition.bane ||
              widget.condition.name.contains("poison") ||
              widget.condition == Condition.infect ||
              widget.condition == Condition.brittle) {
            _runAnimation();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double scale = getScaleByReference(context);
    // lastCommandIndex = gameState.commandIndex.value;

    return ValueListenableBuilder<bool>(
        valueListenable: animate,
        builder: (context, value, child) {
          return ShakeAnimatedWidget(
              duration: const Duration(milliseconds: 333),
              enabled: animate.value,
              alignment: Alignment.center,
              shakeAngle: Rotation.deg(x: 0, y: 0, z: 30),
              child: Image(
                height: widget.size * scale,
                filterQuality: FilterQuality.medium,
                image: AssetImage(widget.gfx),
              ));
        });
  }
}
