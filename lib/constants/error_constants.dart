class ErrorCode {
  static const int NotFound = 400;
  static const int GeneralException = 500;
  static const int FileCreationFailure = 501;
  static const int DriveAPIInitializaitonFailure = 502;
  static const int DriveAPIRequestFailure = 503;
}

class ErrorMessage {
  static String getErrorMessage(int errorCode) {
    switch(errorCode) {
      case ErrorCode.FileCreationFailure:
        return FileCreationFailureErrorMessage;
      case ErrorCode.DriveAPIInitializaitonFailure:
        return DriveAPIInitializaitonFailureErrorMessage;
      case ErrorCode.DriveAPIRequestFailure:
        return DriveAPIRequestFailureErrorMessage;
      case ErrorCode.NotFound:
        return NotFoundErrorMessage;
      case ErrorCode.GeneralException:
      default:
        return GeneralExceptionErrorMessage;
    }
  }
  static const String GeneralExceptionErrorMessage = 'Oops. Something went wrong.';
  static const String FileCreationFailureErrorMessage = 'File creation failed.';
  static const String NotFoundErrorMessage = 'Not found.';
  static const String DriveAPIInitializaitonFailureErrorMessage = 'Drive API initialization failed.';
  static const String DriveAPIRequestFailureErrorMessage = 'Drive API request failed.';
}