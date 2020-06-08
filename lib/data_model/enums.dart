enum ReceiptStatusType
{
  Unknown,
  Uploaded,
  Assigned,
  Decoded,
  Reviewed,
  Deleted,
  Archived
}

enum DecodeStatusType
{
  Unknown,
  Success,
  ExtractTextFailed,
  MaybeNotValidReceipt,
  UnrecognizedFormat,
  PartiallyDecoded
}

enum IRImageSource
{
  Gallary,
  Camera
}

enum ReportStatusType
{
  Unknown,
  Active,
  Submitted,
  Deleted
}

enum SaleExpenseType {
  Expense,
  Sale
}

enum ReceiptSortType {
  UploadTime,
  ReceiptTime,
  CompanyName,
  Amount,
  Category
}

enum ReportSortType {
  CreateTime,
  UpdateTime,
  GroupName,
}

enum FiscYear
{
  Current,
  Previous,
}

enum MainScreenPages {
  home,
  expenses,
  sales,
  functions,
  settings
}

enum ReceiptsSubPages {
  reviewed,
  unreviewed,
  archived,
  groups
}

enum VendorStatusType {
  Active,
  Deleted
}

enum ProductStatusType {
  Active,
  Deleted
}

enum PaymentStatusType {
  FullyPaid,
  PartiallyPaid,
  Overdue
}