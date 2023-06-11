import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/transactions_modify/add_expense_txn_page.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    }, []);

    useEffect(() {
      if (modifySuccess.value) {
        context
            .read<ExpenseTxnBloc>()
            .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
      }
    }, [modifySuccess.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          expenseCategory.title ?? "",
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
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.setting),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
              builder: (context, state) {
                if (state is ExpenseTxnLoaded) {
                  return Text(
                    "USD ${state.total}",
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
            Column(
              children: [
                Text(
                  "Budget",
                ),
                Text(
                  "${expenseCategory.budget}",
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: BlocListener<TransactionsModifyBloc,
                    TransactionsModifyState>(
                  listener: (contex, state) {
                    if (state is ExpenseTxnAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Transaction added!")));
                      Navigator.pop(context);
                    }
                  },
                  child: BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                    builder: (context, state) {
                      if (state is ExpenseTxnLoaded) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.expenseTxns.length,
                          itemBuilder: (context, index) {
                            final item = state.expenseTxns[index];
                            return _txnItem(
                              context,
                              item: item,
                            );
                          },
                        );
                      }
                      return Text("Empty transactions");
                    },
                  ),
                ),
              ),
            ),
          ],
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
      child: Material(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
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
                    if (item.notes != null)
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
              Text("USD ${item.amount}")
            ],
          ),
        ),
      ),
    );
  }
}
