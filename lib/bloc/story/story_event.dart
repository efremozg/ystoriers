abstract class StoryEvent {}

class PauseStory extends StoryEvent {}

class ResumeStory extends StoryEvent {}

class ChangePageStory extends StoryEvent {}

class ChangeStory extends StoryEvent {}

class QuitStory extends StoryEvent {}

class LoadStory extends StoryEvent {}

class LoadedStory extends StoryEvent {
  final Duration duration;

  LoadedStory({
    required this.duration,
  });
}
