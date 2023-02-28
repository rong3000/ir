import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/helper_widgets/confirm-dialog.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/receipt/add_edit_reciept_manual/add_edit_receipt_manual.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/receipt/upload_receipt_image/upload_receipt_image.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intelligent_receipt/data_model/exception_handlers/unsupported_version.dart';
import 'package:intelligent_receipt/data_model/http_statuscode.dart';
import 'package:intelligent_receipt/receipt/archived_receipts_page/archived_receipts_page.dart';
import 'package:intelligent_receipt/main_screen/reports_page/reports_page.dart';

class ReceiptsPage extends StatefulWidget {
  final UserRepository _userRepository;
  final SaleExpenseType _saleExpenseType;
  int _subPageIndex = ReceiptsSubPages.reviewed.index;

  ReceiptsPage({Key key, @required UserRepository userRepository, @required  SaleExpenseType saleExpenseType})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _saleExpenseType = saleExpenseType,
        super(key: key);

  void setTabPageIndex(int pageIndex) {
    _subPageIndex = pageIndex;
  }

  @override
  _ReceiptPageState createState() => new _ReceiptPageState(_subPageIndex);
}

class _ReceiptPageState extends State<ReceiptsPage> with SingleTickerProviderStateMixin {
  int _subPageIndex;

  _ReceiptPageState(int tabPageIndex) {
    _subPageIndex = tabPageIndex;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _getFunctionButton(String buttonText, int subPageIndex) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: new Text(buttonText),
      onPressed: () {
        setState(() {
          _subPageIndex = subPageIndex;
          widget._subPageIndex = subPageIndex;
        });
      },
      color: (subPageIndex == _subPageIndex) ? Colors.lightBlueAccent : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _subPages = <Widget>[
      ReceiptsTabs(
          userRepository: widget._userRepository,
          receiptStatusType: ReceiptStatusType.Reviewed,
          saleExpenseType: widget._saleExpenseType),
      ReceiptsTabs(
          userRepository: widget._userRepository,
          receiptStatusType: ReceiptStatusType.Uploaded,
          saleExpenseType: widget._saleExpenseType),
      ArchivedReceiptsPage(userRepository: widget._userRepository, saleExpenseType: widget._saleExpenseType),
    ];
    return BlocListener(
      bloc: BlocProvider.of<MainScreenBloc>(context),
      listener: (BuildContext context, MainScreenState state) {
        if (state is GoToPageState) {
          GoToPageState goToPageState = state as GoToPageState;
          _subPageIndex = goToPageState.subPageIndex;
          widget._subPageIndex = _subPageIndex;
          BlocProvider.of<MainScreenBloc>(context).dispatch(ResetToNormalEvent());
        }
      },
      child: Scaffold(
        body: _subPages[_subPageIndex],
        bottomNavigationBar: BottomAppBar(
          color: Colors.white30,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getFunctionButton(allTranslations.text('app.receipts-page.reviewed-button-text'), ReceiptsSubPages.reviewed.index),
              _getFunctionButton(allTranslations.text('app.receipts-page.unreviewed-button-text'), ReceiptsSubPages.unreviewed.index),
              _getFunctionButton(allTranslations.text('app.receipts-page.archived-button-text'), ReceiptsSubPages.archived.index),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptsTabs extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final SaleExpenseType _saleExpenseType;

  ReceiptsTabs({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
    @required SaleExpenseType saleExpenseType
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        _saleExpenseType = saleExpenseType,
        super(key: key);

  @override
  _ReceiptsTabsState createState() => _ReceiptsTabsState();
}

class _ReceiptsTabsState extends State<ReceiptsTabs> {
  MainScreenBloc _homeBloc;
  Future<DataResult> _getReceiptsFromServerFuture = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;
  get _saleExpenseType => widget._saleExpenseType;

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  Future<void> reviewAction(int receiptId) async {
    // Try to get the receipt detailed information from server
    DataResult dataResult =
        await _userRepository.receiptRepository.getReceipt(receiptId);
    if (dataResult.success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return AddEditReiptForm(dataResult.obj as Receipt);
        }),
      );
    } else {
      _showInSnackBar("${allTranslations.text("app.receipts-page.failed-review-receipt-message")} \n${dataResult.message}");
    }
  }

  Future<void> archiveAction(int receiptId) async {
    var shouldArchive = await showDialog<bool>(
      context: context, 
      builder: ConfirmDialog.builder(context, 
          title: Text(allTranslations.text('app.receipts-page.archive-receipt-title')),
          content: Text(allTranslations.text('app.receipts-page.archive-receipt-message'))
        ) 
      );
    
    if (shouldArchive){
      DataResult result = await _userRepository.receiptRepository.archiveReceipt(receiptId);
      if (result.success){
        _getReceiptsFromServer(forceRefresh: true).then((result) {
          setState(() {});
        });
      } else {
        _showInSnackBar("${allTranslations.text("app.receipts-page.failed-archive-receipt-message")} \n${result.message}");
      }
    }
  }

  Future<void> _getReceiptsFromServer ({bool forceRefresh : false}) async {
     _getReceiptsFromServerFuture = _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: forceRefresh);
     return _getReceiptsFromServerFuture;
  }

  Future<void> _forceGetReceiptsFromServer() async {
    _getReceiptsFromServerFuture = _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    setState(() {
    });
  }

  Future<void> deleteAndSetState(List<int> receiptIds) async {
    var shouldDelete = await showDialog<bool>(
      context: context,
      builder: ConfirmDialog.builder(context,
        title: Text(allTranslations.text('app.receipts-page.delete-receipt-title')),
        content: Text(allTranslations.text('app.receipts-page.delete-receipt-message'))
      )
    );

    if (shouldDelete) {
      DataResult dataResult = await _userRepository.receiptRepository.deleteReceipts(receiptIds);
      if (dataResult.success) {
        _getReceiptsFromServer();
        setState(() {});
      } else {
        _showInSnackBar("${allTranslations.text("app.receipts-page.failed-delete-receipt-message")} \n${dataResult.message}");
      }
    }
  }

  void deleteAction(int id) {
    List<int> receiptIds = [];
    receiptIds.add(id);
    deleteAndSetState(receiptIds);
  }

  void addAction(int id) {
    print('Add ${id}');
  }

  void removeAction(int id) {
    print('Add ${id}');
  }

  @override
  void initState() {
    super.initState();
    _getReceiptsFromServer();
    _homeBloc = BlocProvider.of<MainScreenBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton:  FancyFab(
        userRepository: _userRepository,
        saleExpenseType: _saleExpenseType,
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Center(
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, MainScreenState state) {
              return FutureBuilder<DataResult>(
                  future: _getReceiptsFromServerFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<DataResult> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text(allTranslations.text('app.common.loading-status'));
                      case ConnectionState.waiting:
                        return new Center(
                            child: new CircularProgressIndicator());
                      case ConnectionState.active:
                        return new Text('');
                      case ConnectionState.done:
                        {
                          if (snapshot.data.success) {
                            List<ReceiptListItem> ReceiptItems = _userRepository
                                .receiptRepository
                                .getReceiptItems(_receiptStatusType, _saleExpenseType);

                            List<ActionWithLabel> actions = [];
                            ActionWithLabel r = new ActionWithLabel();
                            r.action = reviewAction;
                            r.label = allTranslations.text('words.review');
                            r.icon = Icons.edit;
                            ActionWithLabel d = new ActionWithLabel();
                            d.action = deleteAction;
                            d.label = allTranslations.text('words.delete');
                            d.icon = Icons.delete;
                            actions.add(r);
                            if (_receiptStatusType == ReceiptStatusType.Reviewed){
                              var archive = ActionWithLabel();
                              archive.label = allTranslations.text('words.archive');
                              archive.action = archiveAction;
                              archive.icon = Icons.archive;
                              actions.add(archive);
                            }
                            actions.add(d);
                            return  Column(
                              children: <Widget>[
                                Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: ReceiptList(
                                      userRepository: _userRepository,
                                      receiptStatusType: _receiptStatusType,
                                      receiptItems: ReceiptItems,
                                      actions: actions,
                                      forceGetReceiptsFromServer: _forceGetReceiptsFromServer,
                                    )),
                              ],
                            );
                          } else {
                            if (snapshot.data.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
                              return UnsupportedVersion();
                            }
                            return Column(
                              children: <Widget>[
                                Text( '${allTranslations.text("app.receipts-page.failed-load-receipts-message")} ${snapshot.data.messageCode} ${snapshot.data.message}'),
                              ],
                            );
                          }
                        }
                    }
                  });
            }),
      ),
    );
  }
}

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final UserRepository _userRepository;
  final SaleExpenseType _saleExpenseType;

  FancyFab(
      {Key key,
      @required UserRepository userRepository,
      @required SaleExpenseType saleExpenseType,
      this.onPressed,
      this.tooltip,
      this.icon})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _saleExpenseType = saleExpenseType,
        super(key: key) {}

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  UserRepository get _userRepository => widget._userRepository;

  _selectImage() async {
    var source = await _getImageSource();
    if (source != null) {
      var ri = await ImagePicker.pickImage(source: source);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            UploadReceiptImage(userRepository: _userRepository, title: allTranslations.text('app.snap-receipt-page.title'), imageFile: ri, saleExpenseType: widget._saleExpenseType)),
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
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: "add",
        onPressed: null,
        tooltip: allTranslations.text('words.add'),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget camera() {
    return Container(
      child: FloatingActionButton(
        heroTag: "camera",
        onPressed: () {
          animate();
          _selectImage();
          setState(() {

          });
        },

        tooltip: allTranslations.text('app.receipts-page.add-receipt-tooltip'),
        child: Icon(Icons.camera),
//        label: Text("From Camera"),
      ),
    );
  }

  Widget manually() {
    return Container(
      child: FloatingActionButton(
        heroTag: "manually",
        onPressed: () {
          animate();
          Receipt receipt = new Receipt()..receiptTypeId = widget._saleExpenseType.index;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddEditReiptForm(receipt);
            }),
          );
//          setState(() {
//
//          });
        },
        tooltip: allTranslations.text('app.receipts-page.add-receipt-manual-tooltip'),
        child: Icon(Icons.mode_edit),
//        label: Text("From Gallery"),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: "toggle",
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: allTranslations.text('words.toggle'),
        child: Icon(
          Icons.add,
//          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: camera(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: manually(),
        ),
        toggle(),
      ],
    );
  }
}


// The stateful widget + animation controller
class RadialMenu extends StatefulWidget {

  final UserRepository _userRepository;

  RadialMenu(
      {Key key,
        @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {

  AnimationController controller;

  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 900), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(controller: controller, userRepository: _userRepository,);
  }
}


// The Animation
class RadialAnimation extends StatelessWidget {
  RadialAnimation({ Key key, this.controller, this.userRepository,}) :

        scale = Tween<double>(
          begin: 1.5,
          end: 0.0,
        ).animate(
          CurvedAnimation(
              parent: controller,
              curve: Curves.fastOutSlowIn
          ),
        ),
        translation = Tween<double>(
          begin: 0.0,
          end: 100.0,
        ).animate(
          CurvedAnimation(
              parent: controller,
              curve: Curves.linear
          ),
        ),

        rotation = Tween<double>(
          begin: 0.0,
          end: 360.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.3, 0.9,
              curve: Curves.decelerate,
            ),
          ),
        ),

        super(key: key);

  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> translation;
  final Animation<double> rotation;
  final UserRepository userRepository;

  build(context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, builder) {
          return Transform.rotate( // Add rotation
              angle: radians(rotation.value),
              child: Stack(
                  alignment: Alignment.center,
                  children: [
            Transform(
                transform: Matrix4.identity()..translate(
                    (translation.value) * cos(radians(180)),
                    (translation.value) * sin(radians(180))
                ),

                child: FloatingActionButton(
                  heroTag: "cam",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadReceiptImage(
                            userRepository: userRepository,
                            title: allTranslations.text('app.snap-receipt-page.title'),
                          )),
                    );
                  },
                  tooltip: allTranslations.text('app.receipts-page.add-receipt-tooltip'),
                  child: Icon(Icons.camera),
                ),
            ),
                    Transform(
                      transform: Matrix4.identity()..translate(
                          (translation.value) * cos(radians(225)),
                          (translation.value) * sin(radians(225))
                      ),

                      child: FloatingActionButton(
                        heroTag: "man",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return AddEditReiptForm(null);
                            }),
                          );
                        },
                        tooltip: allTranslations.text('app.receipts-page.add-receipt-manual-tooltip'),
                        child: Icon(Icons.mode_edit),
                      ),
                    ),
                    Transform.scale(
                      scale: scale.value - 1.5, // subtract the beginning value to run the opposite animation
                      child: FloatingActionButton(
                        heroTag: "MainOpened",
                          child: Icon(FontAwesomeIcons.plus),
                          onPressed: _close,
                          backgroundColor: Colors.red
                      ),
                    ),
                    Transform.scale(
                      scale: scale.value,
                      child: FloatingActionButton(
                        heroTag: "MainClosed",
                          child:
                          Icon(FontAwesomeIcons.plus),
                          onPressed: _open
                      ),
                    )
                  ])
          );
        });
  }

  _buildButton(double angle, { Color color, IconData icon }) {
    final double rad = radians(angle);
    return Transform(
        transform: Matrix4.identity()..translate(
            (translation.value) * cos(rad),
            (translation.value) * sin(rad)
        ),

        child: FloatingActionButton(
            child: Icon(icon),
            backgroundColor: color,
            onPressed: (){print('a');},
            elevation: 0
        )
    );
  }

  _open() {
    controller.forward();
  }

  _close() {
    controller.reverse();
  }
}