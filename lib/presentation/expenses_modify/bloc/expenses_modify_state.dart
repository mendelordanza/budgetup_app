part of 'expenses_modify_bloc.dart';

@immutable
abstract class ModifyExpensesState {}

class ModifyExpensesInitial extends ModifyExpensesState {}

class ExpenseAdded extends ModifyExpensesState {}

class ExpenseEdited extends ModifyExpensesState {
  final ExpenseCategory updatedCategory;

  ExpenseEdited(this.updatedCategory);
}

class ExpenseRemoved extends ModifyExpensesState {}
