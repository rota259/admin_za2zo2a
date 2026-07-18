import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// One column spec. [minWidth] is what the column needs before the table
/// starts scrolling horizontally; [flex] distributes any surplus.
class ZColumn {
  const ZColumn(
    this.label, {
    this.minWidth = 120,
    this.flex = 1,
    this.priority = 0,
  });

  final String label;
  final double minWidth;
  final int flex;

  /// Higher = dropped sooner when space is tight. 0 never drops.
  final int priority;
}

/// A responsive table.
///
/// Two-stage overflow strategy, so a narrow viewport can never break layout:
///   1. drop low-priority columns (highest [ZColumn.priority] first);
///   2. if the survivors still don't fit, scroll horizontally.
class ZTable extends StatelessWidget {
  const ZTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
  });

  final List<ZColumn> columns;

  /// Each row supplies one cell per column, in column order.
  final List<List<Widget>> rows;
  final void Function(int index)? onRowTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final visible = _visibleColumns(constraints.maxWidth);
        final indices = visible.map((c) => columns.indexOf(c)).toList();
        final needed = visible.fold<double>(0, (s, c) => s + c.minWidth);
        final scrolls = needed > constraints.maxWidth;
        final width = scrolls ? needed : constraints.maxWidth;

        final table = SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(columns: visible),
              ...List.generate(
                rows.length,
                (r) => _Row(
                  columns: visible,
                  cells: [for (final i in indices) rows[r][i]],
                  onTap: onRowTap == null ? null : () => onRowTap!(r),
                ),
              ),
            ],
          ),
        );

        if (!scrolls) return table;
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: table,
          ),
        );
      },
    );
  }

  /// Drop optional columns until the remainder fits, keeping priority 0 always.
  List<ZColumn> _visibleColumns(double available) {
    final kept = [...columns];
    double needed() => kept.fold<double>(0, (s, c) => s + c.minWidth);
    while (needed() > available && kept.any((c) => c.priority > 0)) {
      final droppable = kept.where((c) => c.priority > 0).toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
      kept.remove(droppable.first);
    }
    return kept;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.columns});

  final List<ZColumn> columns;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.rowPadH,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          for (final c in columns)
            Expanded(
              flex: c.flex,
              child: Text(
                c.label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: t.text3, letterSpacing: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.columns, required this.cells, this.onTap});

  final List<ZColumn> columns;
  final List<Widget> cells;
  final VoidCallback? onTap;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.rowPadH,
            vertical: AppSpacing.rowPadV,
          ),
          decoration: BoxDecoration(
            color: _hovered ? t.hover : Colors.transparent,
            border: Border(bottom: BorderSide(color: t.border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < widget.columns.length; i++)
                Expanded(
                  flex: widget.columns[i].flex,
                  child: widget.cells[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
