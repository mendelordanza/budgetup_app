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
      final paidRecurringBills =
          await recurringBillsRepo.getPaidRecurringBills(DateTime.now());

      emit(RecurringBillsLoaded(
        total: getPaidRecurringBillTotal(paidRecurringBills),
        recurringBills: recurringBills,
        paidRecurringBills: paidRecurringBills,
      ));
    });
    on<AddRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        recurringBillsRepo.saveRecurringBill(event.recurringBill);

        final recurringBills = await recurringBillsRepo.getRecurringBills();
        final paidRecurringBills =
            await recurringBillsRepo.getPaidRecurringBills(DateTime.now());

        emit(RecurringBillsLoaded(
          total: getPaidRecurringBillTotal(paidRecurringBills),
          recurringBills: recurringBills,
          paidRecurringBills: paidRecurringBills,
        ));
      }
    });
    on<EditRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        recurringBillsRepo.saveRecurringBill(event.recurringBill);

        final recurringBills = await recurringBillsRepo.getRecurringBills();
        final paidRecurringBills =
            await recurringBillsRepo.getPaidRecurringBills(DateTime.now());

        emit(RecurringBillsLoaded(
          total: getPaidRecurringBillTotal(paidRecurringBills),
          recurringBills: recurringBills,
          paidRecurringBills: paidRecurringBills,
        ));
      }
    });
    on<RemoveRecurringBill>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        final state = this.state as RecurringBillsLoaded;

        if (event.recurringBill.id != null) {
          recurringBillsRepo.deleteRecurringBill(event.recurringBill.id!);
          final paidRecurringBills =
              await recurringBillsRepo.getPaidRecurringBills(DateTime.now());

          emit(
            RecurringBillsLoaded(
              total: getPaidRecurringBillTotal(paidRecurringBills),
              recurringBills: List.from(state.recurringBills)
                ..remove(event.recurringBill),
              paidRecurringBills: paidRecurringBills,
            ),
          );
        }
      }
    });
    on<AddRecurringBillTxn>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        recurringBillsRepo.addRecurringBillTxn(
            event.recurringBill, event.recurringBillTxn);

        //Transactions
        final recurringBills = await recurringBillsRepo.getRecurringBills();

        //Dashboard Summary
        final paidRecurringBills =
            await recurringBillsRepo.getPaidRecurringBills(DateTime.now());

        emit(RecurringBillsLoaded(
          total: getPaidRecurringBillTotal(paidRecurringBills),
          recurringBills: recurringBills,
          paidRecurringBills: paidRecurringBills,
        ));
      }
    });
    on<RemoveRecurringBillTxn>((event, emit) async {
      if (state is RecurringBillsLoaded) {
        final currentState = state as RecurringBillsLoaded;

        recurringBillsRepo.deleteRecurringBillTxn(event.recurringBillTxn);

        final index = currentState.recurringBills
            .indexWhere((element) => element.id == event.recurringBill.id);

        final newRecurringBill = event.recurringBill.copy(
            recurringBillTxns: event.recurringBill.recurringBillTxns
              ?..removeWhere((element) => element.id == event.recurringBillTxn.id));
        //Update the list
        currentState.recurringBills[index] = newRecurringBill;

        //Update dashboard summary
        final updatePaidRecurringBills = currentState.paidRecurringBills
          ..removeWhere((element) => element.id == event.recurringBill.id);

        emit(
          RecurringBillsLoaded(
            total: getPaidRecurringBillTotal(updatePaidRecurringBills),
            recurringBills: List.from(currentState.recurringBills),
            paidRecurringBills: updatePaidRecurringBills,
          ),
        );
      }
    });
  }

  getPaidRecurringBillTotal(List<RecurringBill> paidRecurringBills) {
    var total = 0.0;
    paidRecurringBills.forEach((element) {
      total += element.amount ?? 0.0;
    });
    return total;
  }
}
