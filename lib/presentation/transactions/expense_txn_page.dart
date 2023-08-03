import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/delete_dialog.dart';
import 'package:budgetup_app/presentation/expenses/bloc/single_category_cubit.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/add_expense_txn_page.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:emoji_data/emoji_data.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/date_helper.dart';
import '../custom/custom_floating_button.dart';

class ExpenseTxnPage extends HookWidget {
  final ExpenseCategory expenseCategory;

  ExpenseTxnPage({required this.expenseCategory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SingleCategoryCubit>().getCategory(expenseCategory);
      });
      return null;
    }, []);
    useEffect(() {
      context
          .read<ExpenseTxnBloc>()
          .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<SingleCategoryCubit, SingleCategoryState>(
          builder: (context, state) {
            if (state is SingleCategoryLoaded) {
              return Text(
                "${state.expenseCategory.icon ?? Emoji.objects[49]} ${state.expenseCategory.title}",
                textAlign: TextAlign.center,
              );
            }
            return Text(
              "${expenseCategory.icon ?? Emoji.objects[49]} ${expenseCategory.title}",
              textAlign: TextAlign.center,
            );
          },
        ),
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
        actions: [
          BlocBuilder<SingleCategoryCubit, SingleCategoryState>(
            builder: (context, state) {
              if (state is SingleCategoryLoaded) {
                return PopupMenuButton(
                    // add icon, by default "3 dot" icon
                    icon: Icon(Iconsax.more),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Text("Edit"),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text("Delete"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 0) {
                        Navigator.pushNamed(
                          context,
                          RouteStrings.addCategory,
                          arguments: state.expenseCategory,
                        );
                      } else if (value == 1) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeleteDialog(
                              title: "Delete Category",
                              description:
                                  "This will also delete transactions under this category. Are you sure you want to delete this category?",
                              onPositive: () {
                                context.read<ModifyExpensesBloc>().add(
                                    RemoveExpenseCategory(
                                        expenseCategory:
                                            state.expenseCategory));
                              },
                              onNegative: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      }
                    });
              }
              return PopupMenuButton(
                  icon: Icon(Iconsax.more),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Delete"),
                      ),
                    ];
                  },
                  onSelected: (value) {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Overall Total",
                textAlign: TextAlign.center,
              ),
              BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                builder: (context, state) {
                  if (state is ExpenseTxnLoaded) {
                    return Text(
                      decimalFormatterWithSymbol(number: state.total),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }
                  return const Text(
                    "USD 0.00",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 24.0,
              ),
              Expanded(
                child: BlocListener<TransactionsModifyBloc,
                    TransactionsModifyState>(
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
                  child: BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                    builder: (context, state) {
                      if (state is ExpenseTxnLoaded &&
                          state.expenseTxns.isNotEmpty) {
                        return GroupedListView(
                          elements: state.expenseTxns,
                          groupBy: (element) => DateTime(
                              element.updatedAt!.year,
                              element.updatedAt!.month),
                          itemComparator: (item1, item2) {
                            return getMonthFromDate(item1.updatedAt!)
                                .compareTo(getMonthFromDate(item2.updatedAt!));
                          },
                          groupComparator: (item1, item2) {
                            return item2.compareTo(item1);
                          },
                          groupSeparatorBuilder: (value) {
                            final totalByMonth = expenseCategory
                                .copy(expenseTransactions: state.expenseTxns)
                                .getTotalByDate(DateFilterType.monthly, value);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDate(value, "MMMM yyyy"),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "----------------",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    decimalFormatterWithSymbol(
                                        number: totalByMonth),
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
                            return _txnItem(
                              context,
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
                                  expenseCategory: expenseCategory,
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
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            RouteStrings.addTransaction,
            arguments: ExpenseTxnArgs(
              expenseCategory: expenseCategory,
            ),
          );
        },
      ),
    );
  }

  Widget _txnItem(
    BuildContext context, {
    required ExpenseTxn item,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ValueKey(item.id!),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: ScrollMotion(),
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.updatedAt != null)
                          Text(
                            formatDate(item.updatedAt!, "MMMM dd, yyyy"),
                          ),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.receipt_edit,
                                  size: 18.0,
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  item.notes!,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                  Text(
                    decimalFormatterWithSymbol(number: item.amount ?? 0.00),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
