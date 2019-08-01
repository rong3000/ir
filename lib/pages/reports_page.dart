import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'receipt.dart';

class DataTableDemo extends StatefulWidget {
  DataTableDemo() : super();

  final String title = "Data Table Flutter Demo";

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
  List<Receipt> receipts;
  List<Receipt> selectedReceipts;
  bool sort;

  @override
  void initState() {
    sort = false;
    selectedReceipts = [];
    receipts = Receipt.getReceipts();
    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        receipts.sort((a, b) => a.Date.compareTo(b.Date));
      } else {
        receipts.sort((a, b) => b.Date.compareTo(a.Date));
      }
    }
  }

  onSelectedRow(bool selected, Receipt receipt) async {
    setState(() {
      if (selected) {
        selectedReceipts.add(receipt);
      } else {
        selectedReceipts.remove(receipt);
      }
    });
  }

  deleteSelected() async {
    setState(() {
      if (selectedReceipts.isNotEmpty) {
        List<Receipt> temp = [];
        temp.addAll(selectedReceipts);
        for (Receipt receipt in temp) {
          receipts.remove(receipt);
          selectedReceipts.remove(receipt);
        }
      }
    });
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortAscending: sort,
        sortColumnIndex: 0,
        columns: [
          DataColumn(
              label: Text("Date"),
              numeric: false,
              tooltip: "This is Date",
              onSort: (columnIndex, ascending) {
                setState(() {
                  sort = !sort;
                });
                onSortColum(columnIndex, ascending);
              }),
          DataColumn(
            label: Text("Amount"),
            numeric: false,
            tooltip: "This is Amount",
          ),
        ],
        rows: receipts
            .map(
              (receipt) => DataRow(
              selected: selectedReceipts.contains(receipt),
              onSelectChanged: (b) {
                print("id ${receipt.id} is Onselect");
                onSelectedRow(b, receipt);
              },
              cells: [
                DataCell(
                  Text(receipt.Date),
                  showEditIcon: true,
                  onTap: () {
                    print('Selected Date cell of id ${receipt.id}');
                  },
                ),
                DataCell(
                  Text(receipt.Amount),
                  showEditIcon: true,
                  onTap: () {
                    print('Selected Amount cell of id ${receipt.id}');
                  },
                ),
              ]),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: dataBody(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('SELECTED ${selectedReceipts.length}'),
                  onPressed: () {},
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: OutlineButton(
                  child: Text('DELETE SELECTED'),
                  onPressed: selectedReceipts.isEmpty
                      ? null
                      : () {
                    deleteSelected();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation){
        return
          Column(
            children: <Widget>[
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: DataTableDemo(),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  child: Wrap(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Container(
                          height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.1: 0.2),
                          child:
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.album),
                              title: Text('Intelligent Receipt'),
                              subtitle: Text(
                                  'Invite your friends to join IR then receive more free automatically scans'),
                            ),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Container(
                          height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.1: 0.2),
                          child:
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.album),
                              title: Text('Intelligent Receipt'),
                              subtitle:
                              Text('Get unlimited automatically scans'),
                            ),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                        child: Container(
                          height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.1: 0.2),
                          child:
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.album),
                              title: Text('Intelligent Receipt'),
                              subtitle: Text(
                                  'We have sent you an email, please click confirm'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          );
      }),
    );
  }
}
