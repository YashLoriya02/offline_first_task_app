import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final spService = SPService();
  final taskLocalRepository = TaskLocalRepository();

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = [];
      for (final task in tasks) {
        taskListInMap.add(task.toMap());
      }
      final res = await http
          .post(
            Uri.parse('${Constants.uri}/task/add/sync'),
            headers: {
              'Content-Type': "application/json",
              'x-auth-token': token,
            },
            body: jsonEncode({'tasksList': taskListInMap}),
          )
          .timeout(
            const Duration(seconds: 7),
          );
      if (res.statusCode != 201) {
        return false;
      }
      // return UserModel.fromJson(res.body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<TaskModel> addTask({
    required String title,
    required String description,
    required DateTime dueAt,
    required String color,
    required String token,
    required String userId,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${Constants.uri}/task/add'),
            headers: {
              'Content-Type': "application/json",
              'x-auth-token': token,
            },
            body: jsonEncode({
              'title': title,
              'description': description,
              'dueAt': dueAt.toIso8601String(),
              'hexColor': color
            }),
          )
          .timeout(
            const Duration(seconds: 3),
          );
      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      // return UserModel.fromJson(res.body);
      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          mongoId: "",
          id: const Uuid().v4(),
          title: title,
          description: description,
          color: hexToRgb(color),
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          isSynced: 0,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse('${Constants.uri}/task/fetch'),
        headers: {'Content-Type': "application/json", 'x-auth-token': token},
      ).timeout(
        const Duration(seconds: 3),
      );
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final listOfTasks = jsonDecode(res.body);
      List<TaskModel> tasksList = [];

      for (var element in listOfTasks) {
        tasksList.add(TaskModel.fromMap(element));
      }

      await taskLocalRepository.insertTasks(tasksList);

      return tasksList;
    } catch (e) {
      final tasks = await taskLocalRepository.getTasks();
      if (tasks != null && tasks.isNotEmpty) {
        return tasks;
      }
      rethrow;
    }
  }
}
