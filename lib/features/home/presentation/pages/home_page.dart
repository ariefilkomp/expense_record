import 'package:expense_record/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_cubit.dart';
import 'package:expense_record/features/home/presentation/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void addExpenseDialog() {
    void addExpense() async {
      final expenseCubit = context.read<ExpenseCubit>();
      final AuthCubit authCubit = context.read<AuthCubit>();
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: authCubit.currentUser!.uid,
        amount: double.parse(amountController.text),
        title: descriptionController.text,
        timestamp: selectedDate!,
        category: 'Pengeluaran',
      );
      expenseCubit.addExpense(expense);

      amountController.clear();
      descriptionController.clear();
      selectedDate = null;
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Pengeluaran'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Keterangan'),
                  ),
                  Row(
                    children: [
                      Text(
                        selectedDate != null
                            ? selectedDate.toString()
                            : 'Pilih tanggal',
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await picker
                              .DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (date) {
                              setStateDialog(() {
                                selectedDate = date;
                              });
                            },
                            locale: picker.LocaleType.id,
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: addExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Catatan Pengeluaran',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_task), onPressed: () {}),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: addExpenseDialog,
        icon: Icon(Icons.add_circle_outline),
        color: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: ElevatedButton(
            onPressed: authCubit.logOut,
            child: Text('Logout'),
          ),
        ),
      ),
    );
  }
}

class CustomPicker extends picker.CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime? currentTime, picker.LocaleType? locale})
    : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return "|";
  }

  @override
  String rightDivider() {
    return "|";
  }

  @override
  List<int> layoutProportions() {
    return [1, 2, 1];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          this.currentLeftIndex(),
          this.currentMiddleIndex(),
          this.currentRightIndex(),
        )
        : DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          this.currentLeftIndex(),
          this.currentMiddleIndex(),
          this.currentRightIndex(),
        );
  }
}
