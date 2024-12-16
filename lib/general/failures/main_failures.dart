import 'package:freezed_annotation/freezed_annotation.dart';
part 'main_failures.freezed.dart';
@freezed
class MainFailure with _$MainFailure {
  const factory MainFailure.serverFailure({required String errorMessage}) =
      ServerFailure;
}