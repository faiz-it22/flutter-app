import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

abstract class OnBoardingEvent {}
class OnBoardingPageChanged extends OnBoardingEvent { final int index; OnBoardingPageChanged(this.index); }
class OnBoardingNextPage extends OnBoardingEvent {}
class OnBoardingSkipPage extends OnBoardingEvent {}

class OnBoardingState {
  final int currentIndex;
  OnBoardingState({this.currentIndex = 0});
}

@injectable
class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  final PageController pageController = PageController();

  OnBoardingBloc() : super(OnBoardingState()) {
    on<OnBoardingPageChanged>((event, emit) => emit(OnBoardingState(currentIndex: event.index)));
    on<OnBoardingNextPage>(_onNextPage);
    on<OnBoardingSkipPage>(_onSkipPage);
  }

  void _onNextPage(OnBoardingNextPage event, Emitter<OnBoardingState> emit) {
    if (state.currentIndex < 2) {
      final next = state.currentIndex + 1;
      pageController.animateToPage(next, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onSkipPage(OnBoardingSkipPage event, Emitter<OnBoardingState> emit) {
    pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
