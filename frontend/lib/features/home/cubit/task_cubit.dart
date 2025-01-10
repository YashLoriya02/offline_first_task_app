import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';

part 'task_state.dart';

class NewTaskCubit extends Cubit<NewTaskState> {
  NewTaskCubit() : super(NewTaskInitial());
  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createTask(
      {required String title,
      required String description,
      required DateTime dueAt,
      required Color hexColor,
      required String token,
      required String userId}) async {
    try {
      emit(NewTaskLoading());
      final taskModel = await taskRemoteRepository.addTask(
          title: title,
          userId: userId,
          description: description,
          dueAt: dueAt,
          color: rgbToHex(hexColor),
          token: token);

      await taskLocalRepository.insertTask(taskModel);
      emit(NewTaskSuccess(taskModel: taskModel));
    } catch (e) {
      emit(NewTaskError(e.toString()));
    }
  }

  Future<List<TaskModel>?> fetchTasks({
    required String token,
  }) async {
    try {
      emit(NewTaskLoading());
      final taskLists = await taskRemoteRepository.getTasks(token: token);
      emit(GetTasksSuccess(taskLists));
    } catch (e) {
      emit(NewTaskError(e.toString()));
    }
  }

  Future<void> fetchUnSyncedTasks(String token) async {
    try {
      final taskLists = await taskLocalRepository.getUnSyncedTasks();
      if (taskLists.isNotEmpty) {
        bool isCompleted = await taskRemoteRepository.syncTasks(
            token: token, tasks: taskLists);

        if (isCompleted) {
          for (final t in taskLists) {
            await taskLocalRepository.updateSync(t.id, 1);
          }
        }
      } else {
        return;
      }
    } catch (e) {
      emit(NewTaskError(e.toString()));
    }
  }
}
