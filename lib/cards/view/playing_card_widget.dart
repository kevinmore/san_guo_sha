import 'package:flutter/material.dart';
import 'package:san_guo_sha/cards/model/card_value.dart';
import 'package:san_guo_sha/cards/util/get_good_font_size.dart';
import '../model/playing_card.dart';
import '../util/card_aspect_ratio.dart';
import 'card_images_mapping.dart';
import 'card_texts_mapping.dart';

class PlayingCardWidget extends StatefulWidget {
  final PlayingCard card;
  final bool isFacingDown;
  final bool isSelectable;
  final double? height;

  const PlayingCardWidget({
    Key? key,
    required this.card,
    this.isFacingDown = false,
    this.isSelectable = false,
    this.height,
  }) : super(key: key);

  @override
  State<PlayingCardWidget> createState() => _PlayingCardWidgetState();
}

class _PlayingCardWidgetState extends State<PlayingCardWidget> {
  bool _isHovered = false;
  final double _defaultHeight = 400;

  Widget createCardContent(BuildContext context) {
    if (widget.isFacingDown) {
      return Image.asset(
        "assets/card_images/deck/card_back.png",
        fit: BoxFit.fill,
      );
    }

    switch (widget.card.type) {
      case CardType.role:
        final roleCard = widget.card as RoleCard;
        return Image.asset(
          roleCardImageMap[roleCard.value]!,
          fit: BoxFit.fill,
        );
      case CardType.character:
        final charCard = widget.card as CharacterCard;
        return Image.asset(
          characterCardImageMap[charCard.value]!,
          fit: BoxFit.fill,
        );
      case CardType.deck:
        final deckCard = widget.card as DeckCard;
        return LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : constraints.maxHeight * playingCardAspectRatio;
            double height = constraints.hasBoundedHeight
                ? constraints.maxHeight
                : constraints.maxWidth / playingCardAspectRatio;

            // these magic numbers are based on measurements
            // taken from a few decks of standard decks of cards.
            double innerWidth = width * 1.6875 / 2.5;
            double innerHeight = height * 2.8125 / 3.5;
            double sideSpace = (width - innerWidth) / 2.0;
            double suitHeight = height * 0.12;
            double labelSuitHeight = suitHeight / 2.0;
            double sideOffset = width * 0.03;
            double topOffset = height * 0.05;

            Widget label = Text(
              deckCardValueTextMap[deckCard.value]!,
              style: TextStyle(
                  color: suitColorMap[deckCard.suit],
                  fontSize: getGoodFontSize(
                      "I0",
                      Theme.of(context).textTheme.labelLarge!,
                      sideSpace * .45)),
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
            );
            Widget suit = SizedBox(
              height: labelSuitHeight,
              child: Image.asset(suitSymbolMap[deckCard.suit]!),
            );

            Widget cornerContainer = SizedBox(
              width: sideSpace,
              child: Column(children: [label, suit]),
            );

            return Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    deckCardImageMapList[deckCard.deck]
                        [deckCard.suit]![deckCard.value]!,
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: sideOffset,
                    top: topOffset,
                    child: cornerContainer,
                  )
                ],
              ),
            );
          },
        );
    }
  }

  Widget createCard(BuildContext context) {
    return Card(
      elevation: _isHovered ? 8.0 : 2.0,
      shape: RoundedRectangleBorder(
        side: _isHovered
            ? const BorderSide(color: Colors.blue, width: 3)
            : const BorderSide(),
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: createCardContent(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = createCard(context);
    return SizedBox(
      height: widget.height ?? _defaultHeight,
      width: (widget.height ?? _defaultHeight) * playingCardAspectRatio,
      child: widget.isSelectable
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) => setState(() {
                _isHovered = true;
              }),
              onExit: (event) => setState(() {
                _isHovered = false;
              }),
              child: cardWidget,
            )
          : cardWidget,
    );
  }
}