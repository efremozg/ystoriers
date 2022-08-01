import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y_storiers/bloc/story/story_event.dart';
import 'package:y_storiers/bloc/story/story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  StoryBloc() : super(StoryIdle());

  Duration? duration;

  @override
  Stream<StoryState> mapEventToState(
    StoryEvent event,
  ) async* {
    if (event is LoadStory) {
      print('loading');
      yield StoryLoading();
    }
    if (event is LoadedStory) {
      print('loaded');
      duration = event.duration;
      yield StoryLoaded();
    }
    if (event is PauseStory) {
      yield StoryPaused();
    }
    if (event is ResumeStory) {
      yield StoryResumed();
    }
    if (event is ChangePageStory) {
      yield StoryChangePage();
      yield StoryIdle();
    }
  }
}
