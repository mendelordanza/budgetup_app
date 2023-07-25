part of 'all_txns_cubit.dart';

@immutable
abstract class AllTxnsState {}

class AllTxnsInitial extends AllTxnsState {}

class AllTxnsLoaded extends AllTxnsState {
  final List<ExpenseCategory> categories;
  final List<ExpenseTxn> transactions;

  AllTxnsLoaded({required this.categories, required this.transactions});
}
