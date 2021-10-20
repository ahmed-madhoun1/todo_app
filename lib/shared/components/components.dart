import 'package:flutter/material.dart';
import 'package:todo_app/shared/app_cubit/app_cubit.dart';

/// Custom Field
TextFormField defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function(String)? onSubmit,
  Function(String)? onChange,
  bool isPassword = false,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function()? suffixPressed,
  Function()? onTap,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            prefix,
          ),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: suffixPressed,
                  icon: Icon(suffix),
                )
              : null,
          border: const OutlineInputBorder()),
      onTap: onTap,
    );

/// Task Item
Widget buildTaskItem(Map task, BuildContext context) => Dismissible(
      key: Key(task['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Colors.lightBlue,
                ),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          Text(
                            task['time'],
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            task['date'],
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    AppCubit.get(context)
                        .updateTaskStatus(status: 'done', taskId: task['id']);
                  },
                  icon: const Icon(Icons.check_box_outlined),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: () {
                    AppCubit.get(context).updateTaskStatus(
                        status: 'archive', taskId: task['id']);
                  },
                  icon: const Icon(Icons.archive_outlined),
                  color: Colors.black38,
                )
              ]),
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteTask(taskId: task['id']);
      },
    );

/// Tasks Builder Item
Widget tasksBuilder({required List<Map> tasks}) => tasks.isNotEmpty
    ? ListView.builder(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        itemCount: tasks.length)
    : Container(
        alignment: Alignment.center,
        child: const Text(
          'Tasks empty',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      );
