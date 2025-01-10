import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/task_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:intl/intl.dart';

class AddNewTaskPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => AddNewTaskPage());

  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  Color selectedColor = Color.fromRGBO(246, 222, 194, 1);
  final formKey = GlobalKey<FormState>();

  void createTask() async {
    AuthLoggedIn user = context.read<AuthCubit>().state as AuthLoggedIn;
    if (formKey.currentState!.validate()) {
      await context.read<NewTaskCubit>().createTask(
          title: title.text.trim(),
          description: description.text.trim(),
          dueAt: selectedDate,
          hexColor: selectedColor,
          token: user.user.token,
          userId: user.user.id);
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Task"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: GestureDetector(
              onTap: () async {
                final insideSelectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    Duration(days: 90),
                  ),
                );
                if (insideSelectedDate != null) {
                  setState(() {
                    selectedDate = insideSelectedDate;
                  });
                }
              },
              child: Text(
                DateFormat('y-MM-DD').format(selectedDate),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NewTaskCubit, NewTaskState>(
        listener: (context, state) {
          if (state is NewTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(state.error),
                ),
              ),
            );
          } else if (state is NewTaskSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text("Task Added Successfully"),
                ),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is NewTaskLoading) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10,
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "Title should not be empty.";
                      }
                      return null;
                    },
                    controller: title,
                    decoration: InputDecoration(
                      hintText: "Enter Title",
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "Description should not be empty.";
                      }
                      return null;
                    },
                    controller: description,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter Description",
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Select color",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  ColorPicker(
                      subheading: Text(
                        "Select a different shade",
                        style: TextStyle(fontSize: 16),
                      ),
                      pickersEnabled: {
                        ColorPickerType.wheel: true,
                      },
                      color: selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      }),
                  SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: createTask,
                    child: Text(
                      "SUBMIT",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
