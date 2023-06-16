import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/transactions_modify/add_expense_txn_page.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:emoji_data/emoji_data.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/date_helper.dart';
import '../custom/custom_floating_button.dart';

class ExpenseTxnPage extends HookWidget {
  final ExpenseCategory expenseCategory;

  const ExpenseTxnPage({required this.expenseCategory, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modifySuccess = useState<bool>(false);

    useEffect(() {
      context
          .read<ExpenseTxnBloc>()
          .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
      return null;
    }, []);

    useEffect(() {
      if (modifySuccess.value) {
        context
            .read<ExpenseTxnBloc>()
            .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
      }
      return null;
    }, [modifySuccess.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${expenseCategory.icon ?? Emoji.objects[49]} ${expenseCategory.title}",
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton(
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
                  Navigator.pushNamed(context, RouteStrings.addCategory,
                      arguments: expenseCategory);
                } else if (value == 1) {
                  //TODO show alert dialog
                }
              }),
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
              Text(
                "Overall Total",
                textAlign: TextAlign.center,
              ),
              BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                builder: (context, state) {
                  if (state is ExpenseTxnLoaded) {
                    return Text(
                      decimalFormatter(state.total),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }
                  return Text(
                    "USD 0.00",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              Expanded(
                child: BlocListener<TransactionsModifyBloc,
                    TransactionsModifyState>(
                  listener: (contex, state) {
                    if (state is ExpenseTxnAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Transaction added!")));
                    } else if (state is ExpenseTxnEdited) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Transaction edited!")));
                    }
                    Navigator.pop(context);
                  },
                  child: BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                    builder: (context, state) {
                      if (state is ExpenseTxnLoaded &&
                          state.expenseTxns.isNotEmpty) {
                        return GroupedListView(
                          elements: state.expenseTxns,
                          groupBy: (element) =>
                              "${getMonthFromDate(element.updatedAt!)} ${element.updatedAt?.year}",
                          itemComparator: (item1, item2) {
                            return item2.updatedAt!.compareTo(item1.updatedAt!);
                          },
                          groupSeparatorBuilder: (value) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
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
                      return Center(child: Text("No transactions"));
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
              from: From.txnPage,
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteStrings.addTransaction,
          arguments: ExpenseTxnArgs(
            expenseCategory: expenseCategory,
            expenseTxn: item,
            from: From.txnPage,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
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
                  decimalFormatter(item.amount ?? 0.00),
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
    );
  }
}
