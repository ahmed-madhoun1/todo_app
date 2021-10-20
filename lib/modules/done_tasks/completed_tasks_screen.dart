import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/app_cubit/app_cubit.dart';
import 'package:todo_app/shared/app_cubit/app_states.dart';
import 'package:todo_app/shared/components/components.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var completedTasks = AppCubit.get(context).completedTasks;
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return tasksBuilder(tasks: completedTasks);
        });
  }
}
