import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../data_model/enums.dart';
import '../../data_model/webservice.dart';
import '../../user_repository.dart';


class ReceiptCard extends StatelessWidget {
  final int _index;
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;

  const ReceiptCard({
    Key key,
    @required int index,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
  })  : assert(userRepository != null),
        _index = index,
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        super(key: key);

  CachedNetworkImage getImage(String imagePath) {
    return new CachedNetworkImage(
      imageUrl: Urls.GetImage + "/" + Uri.encodeComponent(imagePath),
      placeholder: (context, url) => new CircularProgressIndicator(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
    theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: getImage(_userRepository
                      .receiptRepository
                      .getReceiptItems(
                      _receiptStatusType)[_index]
                      .imagePath),
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'title',
                      style: titleStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 16.0, 16.0, 0.0),
            child: DefaultTextStyle(
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: descriptionStyle,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  // three line description
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0),
                    child: Text(
                      "description",
                      style: descriptionStyle.copyWith(
                          color: Colors.black54),
                    ),
                  ),
                  Text(
                      '${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[_index].companyName}'),
                  Text(
                      '${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[_index].receiptDatatime}'),
                ],
              ),
            ),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              alignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  child: Text('Review',
                      semanticsLabel:
                      'Review ${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[_index].id}'),
                  textColor: Colors.amber.shade500,
                  onPressed: () {
                    print('pressed');
                  },
                ),
                FlatButton(
                  child: Text('Delete',
                      semanticsLabel:
                      'Delete ${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[_index].id}'),
                  textColor: Colors.amber.shade500,
                  onPressed: () {
                    print('pressed');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}