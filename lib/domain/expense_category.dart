import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
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

  double getOverallTotal() {
    var total = 0.00;
    expenseTransactions?.forEach((e) {
      total += e.amount ?? 0.00;
    });
    return total;
  }

  double getTotalByDate(DateFilterType dateFilterType, DateTime selectedDate) {
    var total = 0.00;
    List<ExpenseTxn>? filteredList;

    switch (dateFilterType) {
      case DateFilterType.daily:
        filteredList = expenseTransactions?.where((element) {
          return removeTimeFromDate(element.updatedAt!) ==
              removeTimeFromDate(selectedDate);
        }).toList();
        break;
      case DateFilterType.weekly:
        filteredList = expenseTransactions?.where((element) {
          return element.updatedAt!.isAfter(getStartDate(selectedDate)) &&
              element.updatedAt!.isBefore(getEndDate(selectedDate));
        }).toList();
        break;
      case DateFilterType.monthly:
        filteredList = expenseTransactions?.where((element) {
          return getMonthFromDate(element.updatedAt!) ==
              getMonthFromDate(selectedDate);
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
    var percentage =
        (getTotalByDate(dateFilterType, selectedDate) / currentBudget);
    return percentage;
  }

  bool isExceeded(DateFilterType dateFilterType, DateTime selectedDate) {
    return getTotalByDate(dateFilterType, selectedDate) >= (budget ?? 0.0);
  }

  ExpenseCategoryEntity toIsar() {
    final isarObject = ExpenseCategoryEntity()
      ..id = id!
      ..title = title
      ..budget = budget
      ..icon = icon
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
