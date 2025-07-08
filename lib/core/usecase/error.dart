import 'package:equatable/equatable.dart';

abstract class ErrorBase extends Equatable {
  final String? message;
  final int? code;

  const ErrorBase({this.message, this.code});

  String get errorerror => "$code Error $message";

  @override
  List<Object?> get props => [message, code];
}

class ServiceError extends ErrorBase {
  const ServiceError({super.message, super.code});

  ServiceError.fromException(ServiceException exception)
    : this(message: exception.message, code: exception.code);
}

class ServiceException extends Equatable implements Exception {
  const ServiceException({this.message, this.code});

  final String? message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}
