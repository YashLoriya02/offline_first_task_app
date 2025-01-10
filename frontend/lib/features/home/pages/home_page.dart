import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<NewTaskCubit>().fetchTasks(token: user.user.token);

    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi)) {
        // ignore: use_build_context_synchronously
        await context.read<NewTaskCubit>().fetchUnSyncedTasks(user.user.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Tasks",
          style: TextStyle(fontSize: 28),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(AddNewTaskPage.route());
              },
              icon: Icon(CupertinoIcons.add),
              iconSize: 30,
            ),
          )
        ],
      ),
      body: BlocBuilder<NewTaskCubit, NewTaskState>(
        builder: (context, state) {
          if (state is NewTaskLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NewTaskError) {
            return Center(
              child: Text(state.error),
            );
          }

          if (state is GetTasksSuccess) {
            final tasks = state.taskLists
                .where((task) =>
                    DateFormat('d').format(task.dueAt) ==
                        DateFormat('d').format(selectedDate) &&
                    selectedDate.month == task.dueAt.month &&
                    selectedDate.year == task.dueAt.year)
                .toList();

            return Column(
              children: [
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: (weekDate) {
                    setState(() {
                      selectedDate = weekDate;
                    });
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return tasks.isNotEmpty
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TaskCard(
                                      color: task.color,
                                      headerText: task.title,
                                      descriptionText: task.description,
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: strengthenColor(
                                        task.color,
                                        0.69,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      DateFormat.jm().format(task.dueAt),
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  "No Tasks found for selected date",
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              );
                      }),
                )
              ],
            );
          }

          return Center(child: const Text("Nothing"));
        },
      ),
    );
  }
}
