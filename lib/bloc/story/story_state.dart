abstract class StoryState {}

class StoryIdle extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {}

class StoryChangePage extends StoryState {}

class StoryPaused extends StoryState {}

class StoryResumed extends StoryState {}
