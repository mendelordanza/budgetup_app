import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'entitlement_state.dart';

class EntitlementCubit extends Cubit<EntitlementState> {
  EntitlementCubit() : super(EntitlementInitial());
}
