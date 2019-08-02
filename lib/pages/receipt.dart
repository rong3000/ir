class Receipt {
  int id;
  String Date;
  String Amount;
  String Company;
  String Category;
  String Actions;

  Receipt({this.id, this.Date, this.Amount, this.Company, this.Category, this.Actions});

  static List<Receipt> getReceipts() {
    return <Receipt>[
      Receipt(id: 1, Date: "19/06/2019", Company: "Coles", Category: "Banana", Actions: "View & Modify", Amount: "100.00"),
      Receipt(id: 2, Date: "17/05/2019", Company: "Coles", Category: "Banana", Actions: "View & Modify", Amount: "57.80"),
      Receipt(id: 3, Date: "22/03/2019", Company: "Coles", Category: "Banana", Actions: "View & Modify", Amount: "666.66"),
      Receipt(id: 4, Date: "15/03/2019", Company: "Coles", Category: "Banana", Actions: "View & Modify", Amount: "49.95"),
      Receipt(id: 5, Date: "12/03/2019", Company: "Coles", Category: "Banana", Actions: "View & Modify", Amount: "87.75"),
    ];
  }
}