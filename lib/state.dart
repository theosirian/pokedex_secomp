import './model.dart';

abstract class LoadState {}

class InitialState extends LoadState {}

class LoadingState extends LoadState {}

class SuccessState extends LoadState {
  final List<PokemonModel> data;

  SuccessState({
    this.data,
  });
}

class FailureState extends LoadState {
  final String error;

  FailureState({
    this.error,
  });
}
