import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/components/expense_summary.dart';
import 'package:untitled3/components/expense_tile.dart';
import 'package:untitled3/data/expense_data.dart';
import 'package:untitled3/models/expense_items.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final newExpenseNameController = TextEditingController();
  final newExpenseDollarAmountController = TextEditingController();
  final newExpenseCentsAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  void addNewExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add new expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newExpenseNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Expense Name'),
            ),
            Row(
              children: [
                // Dollars
                Expanded(
                  child: TextField(
                    controller: newExpenseDollarAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Dollars'),
                  ),
                ),
                // Cents
                Expanded(
                  child: TextField(
                    controller: newExpenseCentsAmountController,
                    decoration: InputDecoration(labelText: 'Cents'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without any action
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.deepOrangeAccent.shade400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              save(); // Save the new expense
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteExpense(ExpenseItems expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteNewExpense(expense);
  }

  void save() {
    if (newExpenseNameController.text.isNotEmpty &&
        newExpenseDollarAmountController.text.isNotEmpty &&
        newExpenseCentsAmountController.text.isNotEmpty) {
      // Ensure dollar and cents inputs are valid numbers
      double? dollars = double.tryParse(newExpenseDollarAmountController.text);
      double? cents = double.tryParse(newExpenseCentsAmountController.text);

      if (dollars == null || cents == null) {
        // Handle error: invalid number format
        return;
      }

      String amount = '${dollars.toStringAsFixed(0)}.${cents.toStringAsFixed(0)}';
      ExpenseItems newExpense = ExpenseItems(
        name: newExpenseNameController.text,
        amount: amount,
        dateTime: DateTime.now(),
      );

      Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);
    }
    Navigator.of(context).pop(); // Close the dialog after saving
    clear();
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    newExpenseNameController.clear();
    newExpenseDollarAmountController.clear();
    newExpenseCentsAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.transparent, // Ensure this is transparent
        floatingActionButton: FloatingActionButton(
          onPressed: addNewExpense,
          backgroundColor: Colors.indigoAccent,
          child: const Icon(Icons.add),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white38, Colors.purple.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            children: [
              ExpenseSummary(startOfWeek: value.startOfWeekDate()),
              const SizedBox(height: 23),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.getAllExpenseList().length,
                itemBuilder: (context, index) => ExpenseTile(
                  name: value.getAllExpenseList()[index].name,
                  amount: value.getAllExpenseList()[index].amount,
                  dateTime: value.getAllExpenseList()[index].dateTime,
                  deleteTapped: (p0) => deleteExpense(value.getAllExpenseList()[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
