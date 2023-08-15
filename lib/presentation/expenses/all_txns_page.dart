import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/expenses/bloc/all_txns_cubit.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/expense_category.dart';
import '../../helper/colors.dart';
import '../../helper/date_helper.dart';
import '../../helper/route_strings.dart';
import '../custom/custom_floating_button.dart';
import '../custom/delete_dialog.dart';
import '../transactions_modify/add_expense_txn_page.dart';
import '../transactions_modify/bloc/transactions_modify_bloc.dart';
import 'bloc/expense_bloc.dart';

class AllTransactionsPage extends HookWidget {
  const AllTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AllTxnsCubit>().getTxns();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text("All Transactions"),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/icons/ic_arrow_left.svg",
            ),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  BlocListener<TransactionsModifyBloc, TransactionsModifyState>(
                listener: (contex, state) {
                  if (state is ExpenseTxnAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction added")));
                    Navigator.pop(context);
                  } else if (state is ExpenseTxnEdited) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction edited")));
                    Navigator.pop(context);
                  }
                },
                child: BlocBuilder<AllTxnsCubit, AllTxnsState>(
                  builder: (context, state) {
                    if (state is AllTxnsLoaded &&
                        state.transactions.isNotEmpty) {
                      return GroupedListView(
                        padding: EdgeInsets.only(bottom: 100.0),
                        elements: state.transactions,
                        groupBy: (element) => DateTime(
                            element.updatedAt!.year, element.updatedAt!.month),
                        itemComparator: (item1, item2) {
                          return getMonthFromDate(item1.updatedAt!)
                              .compareTo(getMonthFromDate(item2.updatedAt!));
                        },
                        groupComparator: (item1, item2) {
                          return item2.compareTo(item1);
                        },
                        groupSeparatorBuilder: (value) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatDate(value, "MMMM yyyy"),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemBuilder: (context, item) {
                          final category = state.categories.firstWhere(
                              (element) => element.id == item.categoryId);
                          return _txnItem(
                            context,
                            expenseCategory: category,
                            item: item,
                          );
                        },
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No transactions yet"),
                        TextButton(
                          onPressed: () async {
                            Navigator.pushNamed(
                              context,
                              RouteStrings.addTransaction,
                              arguments: ExpenseTxnArgs(
                                expenseCategory: null,
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.add),
                              Text("Add your first transaction"),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseCategoryLoaded &&
              state.expenseCategories.isNotEmpty) {
            return CustomFloatingButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RouteStrings.addTransaction,
                  arguments: ExpenseTxnArgs(
                    expenseCategory: null,
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _txnItem(
    BuildContext context, {
    required ExpenseCategory expenseCategory,
    required ExpenseTxn item,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteStrings.addTransaction,
            arguments: ExpenseTxnArgs(
              expenseCategory: expenseCategory,
              expenseTxn: item,
            ),
          );
        },
        behavior: HitTestBehavior.translucent,
        child: Slidable(
          // Specify a key if the Slidable is dismissible.
          key: ValueKey(item.id!),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteDialog(
                        title: "Delete Transaction",
                        description:
                            "Are you sure you want to delete this transaction?",
                        onPositive: () {
                          context.read<TransactionsModifyBloc>().add(
                              RemoveExpenseTxn(
                                  expenseCategory: expenseCategory,
                                  expenseTxn: item));
                        },
                        onNegative: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                autoClose: true,
                backgroundColor: red,
                foregroundColor: Colors.white,
                icon: Iconsax.trash,
                label: 'Delete',
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
            ],
          ),

          // The child of the Slidable is what the user sees when the
          // component is not dragged.
          child: Material(
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 1.0,
              ),
            ),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(item.updatedAt!, "MMM dd, yyyy"),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${item.categoryTitle}"),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text(" - ${item.notes}"),
                        ],
                      )
                    ],
                  ),
                  Text(decimalFormatterWithSymbol(number: item.amount!))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
