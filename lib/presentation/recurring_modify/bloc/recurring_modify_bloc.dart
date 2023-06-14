import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/recurring_bill.dart';
import '../../../domain/recurring_bill_txn.dart';

part 'recurring_modify_event.dart';

part 'recurring_modify_state.dart';

class RecurringModifyBloc
    extends Bloc<RecurringModifyEvent, RecurringModifyState> {
  final RecurringBillsRepository recurringBillsRepo;

  RecurringModifyBloc({
    required this.recurringBillsRepo,
  }) : super(RecurringModifyInitial()) {
    on<AddRecurringBill>((event, emit) async {
      recurringBillsRepo.saveRecurringBill(event.recurringBill);

      emit(RecurringBillAdded(event.selectedDate));
    });
    on<EditRecurringBill>((event, emit) async {
      recurringBillsRepo.saveRecurringBill(event.recurringBill);

      emit(RecurringBillEdited(event.selectedDate));
    });
    on<RemoveRecurringBill>((event, emit) async {
      recurringBillsRepo.deleteRecurringBill(event.recurringBill.id!);
      emit(RecurringBillRemoved(event.selectedDate));
    });
    on<AddRecurringBillTxn>((event, emit) async {
      recurringBillsRepo.addRecurringBillTxn(
          event.recurringBill, event.recurringBillTxn);

      emit(MarkAsPaid(event.selectedDate));
    });
    on<RemoveRecurringBillTxn>((event, emit) async {
      recurringBillsRepo.deleteRecurringBillTxn(event.recurringBillTxn);

      emit(UnmarkAsPaid(event.selectedDate));
    });
  }
}
