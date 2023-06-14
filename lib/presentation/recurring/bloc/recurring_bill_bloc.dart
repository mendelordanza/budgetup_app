import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../recurring_modify/bloc/recurring_modify_bloc.dart';

part 'recurring_bill_event.dart';

part 'recurring_bill_state.dart';

class RecurringBillBloc extends Bloc<RecurringBillEvent, RecurringBillState> {
  final RecurringBillsRepository recurringBillsRepo;
  final RecurringModifyBloc recurringModifyBloc;
  StreamSubscription? _recurringSubscription;

  RecurringBillBloc({
    required this.recurringBillsRepo,
    required this.recurringModifyBloc,
  }) : super(RecurringBillInitial()) {
    _recurringSubscription = recurringModifyBloc.stream.listen((state) {
      if (state is RecurringBillAdded) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is RecurringBillEdited) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is RecurringBillRemoved) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is MarkAsPaid) {
        add(LoadRecurringBills(state.selectedDate));
      } else if (state is UnmarkAsPaid) {
        add(LoadRecurringBills(state.selectedDate));
      }
    });

    on<LoadRecurringBills>((event, emit) async {
      final recurringBills = await recurringBillsRepo.getRecurringBills();
      final paidRecurringBills =
          await recurringBillsRepo.getPaidRecurringBills(event.selectedDate);

      emit(RecurringBillsLoaded(
        total: getPaidRecurringBillTotal(paidRecurringBills),
        recurringBills: recurringBills,
      ));
    });
  }

  getPaidRecurringBillTotal(List<RecurringBill> paidRecurringBills) {
    var total = 0.0;
    paidRecurringBills.forEach((element) {
      total += element.amount ?? 0.0;
    });
    return total;
  }

  @override
  Future<void> close() {
    _recurringSubscription?.cancel();
    return super.close();
  }
}
