import 'package:expense_record/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:expense_record/features/expense/domain/entities/expense.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_cubit.dart';
import 'package:expense_record/features/expense/presentation/cubits/expense_states.dart';
import 'package:expense_record/features/home/presentation/components/my_drawer.dart';
import 'package:expense_record/features/summary/presentation/components/summary_pie_chart.dart';
import 'package:expense_record/features/summary/presentation/cubits/summary_cubit.dart';
import 'package:expense_record/features/summary/presentation/cubits/summary_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? selectedDate;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Belanja Harian';

  void addExpenseDialog() {
    void addExpense() async {
      final expenseCubit = context.read<ExpenseCubit>();
      final authCubit = context.read<AuthCubit>();
      final summaryCubit = context.read<SummaryCubit>();
      final uuid = Uuid();

      if (amountController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Harap isi semua field')));
        return;
      }

      final amount = double.tryParse(amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Format angka tidak valid')));
        return;
      }

      final newExpense = Expense(
        id: uuid.v4(),
        uid: authCubit.currentUser!.uid,
        amount: double.parse(amountController.text),
        title: descriptionController.text,
        timestamp: selectedDate!,
        category: selectedCategory,
      );

      // Kosongkan form & tutup dialog dulu
      amountController.clear();
      descriptionController.clear();
      selectedDate = null;
      Navigator.pop(context);

      // Tambahkan setelah frame saat ini
      WidgetsBinding.instance.addPostFrameCallback((_) {
        expenseCubit.addExpenseOptimistically(newExpense);
      });

      try {
        await expenseCubit.addExpense(newExpense);
        //expenseCubit.fetchExpenses(isFirstFetch: true);
        DateTime now = DateTime.now();
        String formattedMonth = DateFormat('yyyyMM').format(now);
        await Future.delayed(Duration(milliseconds: 1500));
        summaryCubit.fetchSummary(formattedMonth);
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
        );
        expenseCubit.fetchExpenses(isFirstFetch: true);
      }
    }

    final List<String> categories = [
      'Belanja Bulanan',
      'Belanja Harian',
      'Transportasi',
      'Jajan',
      'Jajan - Saku Anak',
      'Amal Sholih',
      'Lainnya',
    ];

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
                  DropdownButton<String>(
                    hint: Text("Pilih kategori"),
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setStateDialog(() {
                        selectedCategory = newValue ?? "Belanja Harian";
                      });
                    },
                    items:
                        categories.map<DropdownMenuItem<String>>((
                          String category,
                        ) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
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

  late ScrollController _scrollController;

  Future<void> firstFetch() async {
    final expenseCubit = context.read<ExpenseCubit>();
    final summaryCubit = context.read<SummaryCubit>();
    expenseCubit.fetchExpenses(isFirstFetch: true);
    DateTime now = DateTime.now();
    String formattedMonth = DateFormat('yyyyMM').format(now);
    summaryCubit.fetchSummary(formattedMonth);
  }

  @override
  void initState() {
    super.initState();
    firstFetch();

    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    descriptionController.dispose();
    _scrollController.dispose();
  }

  void _onScroll() {
    final expenseCubit = context.read<ExpenseCubit>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = expenseCubit.state;
      if (state is ExpenseLoaded && !state.hasReachedEnd) {
        expenseCubit.fetchExpenses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Spendee - Catatan Pengeluaran',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButton: IconButton(
        iconSize: 40,
        onPressed: addExpenseDialog,
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.add_circle_outline),
        ),
        color: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: firstFetch,
        child: Column(
          children: [
            BlocBuilder<SummaryCubit, SummaryState>(
              builder: (context, state) {
                if (state is SummaryInitial || state is SummaryLoading) {
                  return const CircularProgressIndicator();
                }

                if (state is SummaryLoaded) {
                  if (state.summaries == null) {
                    return const Center(child: Text('Belum ada pengeluaran'));
                  } else {
                    return SizedBox(
                      height: 250,
                      child: SummaryPieChart(data: state.summaries!),
                    );
                  }
                }

                return Container();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ExpenseCubit, ExpenseStates>(
                builder: (context, state) {
                  final expenseCubit = context.read<ExpenseCubit>();
                  final summaryCubit = context.read<SummaryCubit>();
                  if (state is ExpenseInitial || state is ExpenseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExpenseError) {
                    return Center(child: Text(state.message));
                  } else if (state is ExpenseLoaded) {
                    if (state.expenses.isEmpty) {
                      return const Center(child: Text('Belum ada pengeluaran'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          state.expenses.length + (state.hasReachedEnd ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index < state.expenses.length) {
                          final exp = state.expenses[index];
                          return Dismissible(
                            key: Key(exp.id), // wajib: unik untuk tiap item
                            direction:
                                DismissDirection
                                    .endToStart, // geser dari kanan ke kiri
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) async {
                              setState(() {
                                state.expenses.removeAt(index);
                              });

                              await expenseCubit.deleteExpense(exp);

                              DateTime now = DateTime.now();
                              String formattedMonth = DateFormat(
                                'yyyyMM',
                              ).format(now);
                              summaryCubit.fetchSummary(formattedMonth);

                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${exp.title} dihapus')),
                              );
                            },
                            child: ListTile(
                              title: Text(exp.title),
                              subtitle: Row(
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(exp.amount),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(exp.category),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                "${exp.timestamp.day}/${exp.timestamp.month}/${exp.timestamp.year}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
