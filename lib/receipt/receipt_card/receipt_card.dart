import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../data_model/enums.dart';
import '../../data_model/webservice.dart';
import '../../user_repository.dart';

class ReceiptCard extends StatelessWidget {
  final int _index;
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final int _type;
  final bool _ascending;

  const ReceiptCard({
    Key key,
    @required int index,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
    @required int type,
    @required bool ascending,
  })  : assert(userRepository != null),
        _index = index,
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        _type = type,
        _ascending = ascending,
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
    final TextStyle companyNameStyle =
        theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle dateStyle = theme.textTheme.subhead;
    final TextStyle amountStyle = theme.textTheme.title;
    print('card state being set');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: SizedBox(
              height: 160,
              child: getImage(_userRepository.receiptRepository
                  .getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index]
                  .imagePath),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: dateStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Receipt Date ${DateFormat().add_yMd().format(_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].receiptDatetime.toLocal())}",
                            style: dateStyle.copyWith(color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Text(
                            '${_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].companyName}',
                            style: companyNameStyle,
                          ),
                        ),
                        Text(
                          'Total ${_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].totalAmount}',
                          style: amountStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: dateStyle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // three line description
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Uploaded ${DateFormat().add_yMd().format(_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].uploadDatetime.toLocal())}",
                            style: dateStyle.copyWith(color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            CategoryName.values[_userRepository
                                    .receiptRepository
                                    .getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index]
                                    .categoryId]
                                .toString()
                                .split('.')[1],
                            style: companyNameStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ButtonTheme.bar(
                  child: ButtonBar(
                    children: <Widget>[
                      OutlineButton(
                          child: Text('Review',
                              style:
                                  companyNameStyle.copyWith(color: Colors.blue),
                              semanticsLabel:
                                  'Review ${_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].id}'),
//                        textColor: Colors.blue.shade500,

                          onPressed: () {
                            print('pressed');
                          },
                          borderSide: BorderSide(color: Colors.blue),
//                          shape: StadiumBorder(),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(6.0))),
                      OutlineButton(
                          child: Text('Delete',
                              style:
                                  companyNameStyle.copyWith(color: Colors.blue),
                              semanticsLabel:
                                  'Delete ${_userRepository.receiptRepository.getSortedReceiptItems(_receiptStatusType, _type, _ascending)[_index].id}'),
                          textColor: Colors.blue.shade500,
                          onPressed: () {
                            print('pressed');
                          },
                          borderSide: BorderSide(color: Colors.blue),
//                          shape: StadiumBorder(),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(6.0))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
