import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/app_cubit/app_cubit.dart';
import 'package:todo_app/shared/app_cubit/app_states.dart';
import 'package:todo_app/shared/components/components.dart';

/// 1.Create states file and define your states
/// 2.Create cubit for this states file and define your events and logic
/// 3.Create bloc provider in your widget and initialize you listener

class HomeScreen extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.check_circle_outline), label: 'Done'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.archive_outlined), label: 'Archive'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates? state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 100.0,
              elevation: 0.0,
              title: Text(
                '${items[cubit.currentIndex].label}',
                style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
              ),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetOpened) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertTask(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          width: double.infinity,
                          height: 400,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 40.0, horizontal: 20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title), // defaultFormField
                                const SizedBox(
                                  height: 20.0,
                                ),
                                defaultFormField(
                                    controller: timeController,
                                    type: TextInputType.none,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Time must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined,
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) => {
                                                timeController.text = value!
                                                    .format(context)
                                                    .toString()
                                              });
                                    }), // defaultFormField
                                const SizedBox(
                                  height: 20.0,
                                ),
                                defaultFormField(
                                    controller: dateController,
                                    type: TextInputType.none,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Date',
                                    prefix: Icons.date_range_outlined,
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2022-05-11'))
                                          .then((value) => {
                                                dateController.text =
                                                    DateFormat.yMMMd()
                                                        .format(value!)
                                                        .toString()
                                              });
                                    }), // defaultFormField
                              ],
                            ),
                          ),
                        ),
                        elevation: 10.0,
                        backgroundColor: Colors.grey[100],
                      )
                      .closed
                      .then((value) => {
                            cubit.changeBottomSheetState(
                                isOpen: false, icon: Icons.edit)
                          });
                  cubit.changeBottomSheetState(isOpen: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: items,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
            ),
          );
        },
      ),
    );
  }
}
