part of 'salary_bloc.dart';

@immutable
abstract class SalaryState {}

class SalaryInitial extends SalaryState {}

class SalaryLoaded extends SalaryState {
  final Salary? salary;
  final double totalExpense;
  final double totalPaidBills;
  final double remainingSalary;

  SalaryLoaded(
      {this.salary,
      required this.totalExpense,
      required this.totalPaidBills,
      this.remainingSalary = 0.00});
}
