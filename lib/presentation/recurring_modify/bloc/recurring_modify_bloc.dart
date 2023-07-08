import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/notification_service.dart';
import 'package:budgetup_app/helper/currency_helper.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/recurring_bill.dart';
import '../../../domain/recurring_bill_txn.dart';

part 'recurring_modify_event.dart';

part 'recurring_modify_state.dart';

class RecurringModifyBloc
    extends Bloc<RecurringModifyEvent, RecurringModifyState> {
  final NotificationService notificationService;
  final RecurringBillsRepository recurringBillsRepo;

  RecurringModifyBloc({
    required this.recurringBillsRepo,
    required this.notificationService,
  }) : super(RecurringModifyInitial()) {
    on<AddRecurringBill>((event, emit) async {
      final id =
          await recurringBillsRepo.saveRecurringBill(event.recurringBill);

      //Schedule Notif
      notificationService.scheduleNotification(
        id,
        "Have you paid your bill yet?",
        "${event.recurringBill.title} amounting to ${decimalFormatterWithSymbol(convertToCurrency(event.recurringBill.amount ?? 0.00))}",
        event.recurringBill.reminderDate!.toIso8601String(),
        event.recurringBill.interval!,
      );

      emit(RecurringBillAdded(event.selectedDate));
    });
    on<EditRecurringBill>((event, emit) async {
      final id =
          await recurringBillsRepo.saveRecurringBill(event.recurringBill);

      //Schedule Notif
      notificationService.scheduleNotification(
        id,
        "Have you paid your bill yet?",
        "${event.recurringBill.title} amounting to ${decimalFormatterWithSymbol(convertToCurrency(event.recurringBill.amount ?? 0.00))}",
        event.recurringBill.reminderDate!.toIso8601String(),
        event.recurringBill.interval!,
      );

      emit(RecurringBillEdited(event.selectedDate));
    });
    on<RemoveRecurringBill>((event, emit) async {
      await recurringBillsRepo.deleteRecurringBill(event.recurringBill.id!);

      notificationService.cancelNotif(event.recurringBill.id!);

      emit(RecurringBillRemoved(event.selectedDate));
    });
    on<ArchiveRecurringBill>((event, emit) async {
      await recurringBillsRepo.softDeleteRecurringBill(
        event.recurringBill,
        event.selectedDate,
      );

      notificationService.cancelNotif(event.recurringBill.id!);

      emit(RecurringBillRemoved(event.selectedDate));
    });
    on<AddRecurringBillTxn>((event, emit) async {
      await recurringBillsRepo.addRecurringBillTxn(
          event.recurringBill, event.recurringBillTxn);
      emit(MarkAsPaid(event.selectedDate));
    });
    on<RemoveRecurringBillTxn>((event, emit) async {
      await recurringBillsRepo.deleteRecurringBillTxn(event.recurringBillTxn);
      emit(UnmarkAsPaid(event.selectedDate));
    });
  }
}
