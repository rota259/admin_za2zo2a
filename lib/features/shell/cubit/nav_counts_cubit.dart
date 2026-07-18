import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../data/repos/nav_counts_repo.dart';

/// Holds the live sidebar badge counts.
///
/// A failure here must never break the shell — the badges simply stay at zero
/// (and therefore hidden) rather than surfacing an error over navigation.
class NavCountsCubit extends Cubit<NavCounts> {
  NavCountsCubit(this._repo) : super(const NavCounts());

  final NavCountsRepo _repo;

  Future<void> load() async {
    try {
      emit(await _repo.fetch());
    } on ApiError {
      emit(const NavCounts());
    }
  }

  /// Call after an action that changes a queue (approve/reject/review) so the
  /// badge stays truthful without a page reload.
  Future<void> refresh() => load();
}
