import 'package:budgetup_app/data/local/entities/expense_txn_entity.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/date_filter/date_bottom_sheet.dart';
import 'package:equatable/equatable.dart';

import '../data/local/entities/expense_category_entity.dart';

class ExpenseCategory extends Equatable {
  final int? id;
  final String? title;
  final String? icon;
  final double? budget;
  final List<ExpenseTxn>? expenseTransactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseCategory({
    this.id,
    this.title,
    this.icon,
    this.budget,
    this.expenseTransactions,
    this.createdAt,
    this.updatedAt,
  });

  double getTotal(DateFilterType dateFilterType, DateTime selectedDate) {
    var total = 0.00;
    List<ExpenseTxn>? filteredList;

    switch (dateFilterType) {
      case DateFilterType.daily:
        filteredList = expenseTransactions?.where((element) {
          return removeTimeFromDate(element.createdAt!) ==
              removeTimeFromDate(selectedDate);
        }).toList();
        break;
      case DateFilterType.weekly:
        filteredList = expenseTransactions?.where((element) {
          return element.createdAt!.isAfter(getStartDate(selectedDate)) &&
              element.createdAt!.isBefore(getEndDate(selectedDate));
        }).toList();
        break;
      case DateFilterType.monthly:
        filteredList = expenseTransactions?.where((element) {
          return getMonthFromDate(element.createdAt!) ==
              getMonthFromDate(selectedDate);
        }).toList();
        break;
      case DateFilterType.yearly:
        filteredList = expenseTransactions?.where((element) {
          return getYearFromDate(element.createdAt!) ==
              getYearFromDate(selectedDate);
        }).toList();
        break;
    }

    filteredList?.forEach((e) {
      total += e.amount ?? 0.00;
    });
    return total;
  }

  double getTotalPercentage(
      DateFilterType dateFilterType, DateTime selectedDate) {
    final currentBudget = budget ?? 0.0;
    var percentage = (getTotal(dateFilterType, selectedDate) / currentBudget);
    return percentage;
  }

  ExpenseCategoryEntity toIsar(ExpenseTxnEntity expenseTxnEntity) {
    final isarObject = ExpenseCategoryEntity()
      ..id = id!
      ..title = title
      ..budget = budget
      ..icon = icon
      ..expenseTransactions.add(expenseTxnEntity)
      ..createdAt = createdAt
      ..updatedAt = updatedAt;
    return isarObject;
  }

  factory ExpenseCategory.fromJson(Map<dynamic, dynamic> json) =>
      ExpenseCategory(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
        budget: json["budget"],
        expenseTransactions: List<ExpenseTxn>.from(json["expenseTransactions"]
            .map((txn) => ExpenseTxn.fromJson(txn.toJson()))),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, Object?> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
        "budget": budget,
        "expenseTransactions": expenseTransactions
      };

  ExpenseCategory copy({
    int? id,
    String? title,
    String? icon,
    double? budget,
    List<ExpenseTxn>? expenseTransactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ExpenseCategory(
        id: id ?? this.id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
        budget: budget ?? this.budget,
        expenseTransactions: expenseTransactions ?? this.expenseTransactions,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        icon,
        budget,
        expenseTransactions,
        createdAt,
        updatedAt,
      ];
}
