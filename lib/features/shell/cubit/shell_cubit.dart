import 'package:flutter_bloc/flutter_bloc.dart';

/// Sidebar collapse state.
///
/// [userCollapsed] is the operator's explicit choice via the rail toggle.
/// The shell also force-collapses below the tablet breakpoint regardless —
/// see `AdminShell`, which combines the two.
class ShellCubit extends Cubit<bool> {
  ShellCubit() : super(false);

  void toggle() => emit(!state);
  void collapse() => emit(true);
}
