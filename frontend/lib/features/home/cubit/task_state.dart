part of 'task_cubit.dart';

sealed class NewTaskState {
  const NewTaskState();
}

final class NewTaskInitial extends NewTaskState {}

final class NewTaskLoading extends NewTaskState {}

final class NewTaskError extends NewTaskState {
  final String error;

  NewTaskError(this.error);
}

final class NewTaskSuccess extends NewTaskState {
  final TaskModel taskModel;

  const NewTaskSuccess({required this.taskModel});
}

final class GetTasksSuccess extends NewTaskState {
  final List<TaskModel> taskLists;

  GetTasksSuccess(this.taskLists);
}
