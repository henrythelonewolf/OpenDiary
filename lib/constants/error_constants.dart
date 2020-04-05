class ErrorCode {
  static const int NotFound = 400;
  static const int GeneralException = 500;
  static const int FileCreationFailure = 501;
}

class ErrorMessage {
  static String getErrorMessage(int errorCode) {
    switch(errorCode) {
      case ErrorCode.FileCreationFailure:
        return FileCreationFailureErrorMessage;
      case ErrorCode.GeneralException:
      default:
        return GeneralExceptionErrorMessage;
    }
  }

  static const String GeneralExceptionErrorMessage = 'Oops. Something went wrong.';
  static const String FileCreationFailureErrorMessage = 'File creation failed.';
  static const String NotFoundErrorMessage = 'Not found.';
}