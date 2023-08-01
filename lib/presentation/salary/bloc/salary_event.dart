part of 'salary_bloc.dart';

@immutable
abstract class SalaryEvent {}

class LoadSalary extends SalaryEvent {
  final DateTime selectedDate;

  LoadSalary({
    required this.selectedDate,
  });
}

class AddSalary extends SalaryEvent {
  final DateTime selectedDate;
  final Salary salary;

  AddSalary({
    required this.salary,
    required this.selectedDate,
  });
}

class SaveSalary extends SalaryEvent {
  final DateTime selectedDate;
  final Salary salary;

  SaveSalary({
    required this.salary,
    required this.selectedDate,
  });
}

class CancelInput extends SalaryEvent {}
