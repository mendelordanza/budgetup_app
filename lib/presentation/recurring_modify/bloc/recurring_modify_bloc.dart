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
      // if (state is RecurringBillsLoaded) {
      //   final state = this.state as RecurringBillsLoaded;
      //
      //   if (event.recurringBill.id != null) {
      //
      //
      //     emit(
      //       RecurringBillsLoaded(
      //         total: getPaidRecurringBillTotal(state.recurringBills),
      //         recurringBills: List.from(state.recurringBills)
      //           ..remove(event.recurringBill),
      //       ),
      //     );
      //   }
      // }
    });
    on<AddRecurringBillTxn>((event, emit) async {
      recurringBillsRepo.addRecurringBillTxn(
          event.recurringBill, event.recurringBillTxn);

      emit(MarkAsPaid(event.selectedDate));

      // if (state is RecurringBillsLoaded) {
      //   recurringBillsRepo.addRecurringBillTxn(
      //       event.recurringBill, event.recurringBillTxn);
      //
      //   //Transactions
      //   final recurringBills = await recurringBillsRepo.getRecurringBills();
      //
      //   final paidRecurringBills =
      //       await recurringBillsRepo.getPaidRecurringBills(event.selectedDate);
      //
      //   emit(RecurringBillsLoaded(
      //     total: getPaidRecurringBillTotal(paidRecurringBills),
      //     recurringBills: recurringBills,
      //   ));
      // }
    });
    on<RemoveRecurringBillTxn>((event, emit) async {
      recurringBillsRepo.deleteRecurringBillTxn(event.recurringBillTxn);

      emit(UnmarkAsPaid(event.selectedDate));

      // if (state is RecurringBillsLoaded) {
      //   final currentState = state as RecurringBillsLoaded;
      //
      //   recurringBillsRepo.deleteRecurringBillTxn(event.recurringBillTxn);
      //
      //   final index = currentState.recurringBills
      //       .indexWhere((element) => element.id == event.recurringBill.id);
      //
      //   final newRecurringBill = event.recurringBill.copy(
      //       recurringBillTxns: event.recurringBill.recurringBillTxns
      //         ?..removeWhere(
      //             (element) => element.id == event.recurringBillTxn.id));
      //   //Update the list
      //   currentState.recurringBills[index] = newRecurringBill;
      //
      //   final paidRecurringBills = currentState.recurringBills.where((element) {
      //     return element.isPaid(event.selectedDate);
      //   }).toList();
      //
      //   emit(
      //     RecurringBillsLoaded(
      //       total: getPaidRecurringBillTotal(paidRecurringBills),
      //       recurringBills: List.from(currentState.recurringBills),
      //     ),
      //   );
      // }
    });
  }
}
