import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:intelligent_receipt/receipt/add_edit_reciept_manual/add_edit_receipt_manual.dart';
import 'package:intelligent_receipt/receipt/upload_receipt_image/upload_receipt_image.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';


class HomePage extends StatefulWidget {
  final UserRepository _userRepository;
  Function(int) action;

  HomePage({Key key, @required UserRepository userRepository, this.action,})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  void setAction(Function(int) newAction) {
    action = newAction;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainScreenBloc _mainScreenBloc;
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
    _mainScreenBloc = BlocProvider.of<MainScreenBloc>(context);
  }

  _selectImage() async {
    var source = await _getImageSource();
    if (source != null) {
      var ri = await ImagePicker.pickImage(source: source, imageQuality: 30);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadReceiptImage(userRepository: _userRepository, title: allTranslations.text('app.snap-receipt-page.title'), imageFile: ri,)),
      );
    }
  }

  Future<ImageSource> _getImageSource() async {
    return showDialog<ImageSource>(
      context: context,
      //barrierDismissible: true, // Allow to be closed without selecting option
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(allTranslations.text('app.select-image-source-dialog.title')),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('words.camera')),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            FlatButton(
              child: Text(allTranslations.text('words.gallery')),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return BlocListener(
        bloc: _mainScreenBloc,
        listener: (BuildContext context, MainScreenState state) {
        },
        child: BlocBuilder(
            bloc: _mainScreenBloc,
            builder: (BuildContext context, MainScreenState state) {
              return Scaffold(
                body: OrientationBuilder(builder: (context, orientation){
                  return
                    Column(
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          child: Wrap(
                            children: <Widget>[
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child: GestureDetector(
                                    onTap: () {
                                      _selectImage();
                                    },
                                    child: Card(
                                      child: ListTile(
                                        title: Text(allTranslations.text('app.home-page.snap-receipt-card-title')),
                                        subtitle: Icon(Icons.photo_camera, size: MediaQuery.of(context).size.height * 0.1,),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                         MaterialPageRoute(builder: (context) => AddEditReiptForm(null)) 
                                      );
                                    },
                                    child: 
                                      Card(
                                      child: ListTile(
                                        title: Text(allTranslations.text('app.home-page.manual-add-card-title')),
                                        subtitle: Icon(Icons.edit, size: MediaQuery.of(context).size.height * 0.1,),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:GestureDetector(
                                    onTap: () {
                                      widget.action(1);
                                    },
                                    child: Card(
                                      child: ListTile(
                                        title: Text(allTranslations.text('app.home-page.view-imported-receipts-card-title')),
                                        subtitle: Icon(Icons.receipt, size: MediaQuery.of(context).size.height * 0.1,),
                                      ),
                                    ),
                                  ),

                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: orientation == Orientation.portrait ? 0.5: 0.25,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.2: 0.4),
                                  child:GestureDetector(
                                    onTap: () {
                                      widget.action(2);
                                    },
                                    child: Card(
                                      child: ListTile(
                                        title: Text(allTranslations.text('app.home-page.view-receipts-group-card-title')),
                                        subtitle: Icon(Icons.collections_bookmark, size: MediaQuery.of(context).size.height * 0.1,),
                                      ),
                                    ),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
//                        Flexible(
//                            fit: FlexFit.tight,
//                            child: Wrap(
//                              children: <Widget>[
//                                FractionallySizedBox(
//                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
//                                  child: Container(
//                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
//                                    child:
//                                    Card(
//                                      child: ListTile(
//                                        leading: Icon(Icons.album),
//                                        title: AutoSizeText(
//                                          'Intelligent Receipt',
//                                          style: TextStyle(fontSize: 18),
//                                          minFontSize: 8,
//                                          maxLines: 1,
//                                          overflow: TextOverflow.ellipsis,
//                                        ),
//                                        subtitle: AutoSizeText(
//                                          'Invite your friends to join IR then receive more free automatically scans',
//                                          style: TextStyle(fontSize: 18),
//                                          minFontSize: 8,
//                                          maxLines: 2,
//                                          overflow: TextOverflow.ellipsis,
//                                        ),
//
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                FractionallySizedBox(
//                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
//                                  child: Container(
//                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
//                                    child:
//                                    Card(
//                                      child: ListTile(
//                                        leading: Icon(Icons.album),
//                                        title: Text('Intelligent Receipt'),
//                                        subtitle:
//                                        Text('Get unlimited automatically scans'),
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                FractionallySizedBox(
//                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
//                                  child: Container(
//                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
//                                    child:
//                                    Card(
//                                      child: ListTile(
//                                        leading: Icon(Icons.album),
//                                        title: Text('Intelligent Receipt'),
//                                        subtitle: Text(
//                                            'We have sent you an email, please click confirm'),
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            )
//                        ),
                      ],
                    );
                }),
              );
            }));
  }

  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not in stock'),
          content: const Text('This item is no longer available'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
