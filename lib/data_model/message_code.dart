class MessageCode {
  static const int UNKNOWN = -1;

  // general error code, starts from 9000
  static const int TIMEOUT = 9000;

  // region Setting related errors, starts from 10000
  static const int CATEGORY_GET_CATEGORIES_FAIL = 10000,
      CATEGORY_NAME_EXIST = 10001,
      CATEGORY_ADD_CATEGORY_FAIL = 10002,
      CATEGORY_RECORD_NOT_FOUND = 10003,
      CATEGORY_UPDATE_CATEGORY_FAIL = 10004,
      CATEGORY_DELETE_FAIL = 10005;
  // endregion

  // region Receipt related errors, starts from 20000
  static const int RECEIPT_DELETE_FAIL = 20000,
      RECEIPT_UPLOAD_IMAGES_FAIL = 20001,
      RECEIPT_ADD_FAIL = 20002,
      RECEIPT_UPDATE_CURRENT_RECEIPT_NOT_FOUND = 20003,
      RECEIPT_UPDATE_FAIL = 20004,
      RECEIPT_GET_RECEIPT_FAIL = 20005,
      RECEIPT_DECODE_FAIL = 20006,
      RECEIPT_ADD_CONTACT_FAIL = 20007,
      RECEIPT_GET_RECEIPTS_BY_USER_ID_FAIL = 20008;
  // endregion
}
