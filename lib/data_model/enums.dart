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
