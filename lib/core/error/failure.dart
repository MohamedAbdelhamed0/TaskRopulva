
abstract class Failure{
  final String message ;
  final String code ;
  const Failure({
    required this.message,
    required this.code,
  });
}

class ServerFailure extends Failure{
  const ServerFailure({
    required super.message,
    required super.code,
  });
}

class InternalFailure extends Failure{
  InternalFailure({required super.message, required super.code});
}