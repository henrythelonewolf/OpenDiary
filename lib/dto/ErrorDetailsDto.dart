import 'package:opendiary/constants/error_constants.dart';

class ErrorDetailsDto {
  int errorCode;
  String errorMessage;
  String get autoErrorMessage => ErrorMessage.getErrorMessage(this.errorCode);
  ErrorDetailsDto({this.errorCode, this.errorMessage});
}