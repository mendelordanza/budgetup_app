import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/recurring_bill_txn.dart';

part 'recurring_bill_event.dart';

part 'recurring_bill_state.dart';

class RecurringBillBloc extends Bloc<RecurringBillEvent, RecurringBillState> {
  final RecurringBillsRepository recurringBillsRepo;

  RecurringBillBloc({
    required this.recurringBillsRepo,
  }) : super(RecurringBillInitial()) {
    on<LoadRecurringBills>((event, emit) async {
      final recurringBills = await recurringBillsRepo.getRecurringBills();
      emit(RecurringBillsLoaded(recurringBills: recurringBills));
    });
    on<AddRecurringBillTxn>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        recurringBillsRepo.addRecurringBillTxn(
            event.recurringBill, event.recurringBillTxn);

        final recurringBills = await recurringBillsRepo.getRecurringBills();

        emit(
          RecurringBillsLoaded(
            recurringBills: recurringBills,
          ),
        );
      }
    });
  }
}
