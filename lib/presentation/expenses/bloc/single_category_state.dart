part of 'single_category_cubit.dart';

@immutable
abstract class SingleCategoryState {}

class SingleCategoryInitial extends SingleCategoryState {}

class SingleCategoryLoaded extends SingleCategoryState {
  final ExpenseCategory expenseCategory;

  SingleCategoryLoaded(this.expenseCategory);
}
