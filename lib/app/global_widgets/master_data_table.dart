import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../core/values/app_colors.dart';

class MasterDataTable<T> extends StatelessWidget {
  final List<DataColumn2> columns;
  final List<T> data;
  final DataRow2 Function(T, int) dataRowBuilder;
  final bool isLoading;
  final String emptyMessage;
  final double? minWidth;
  final double? maxHeight;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;
  final bool showPageSizeSelector;
  final int? rowsPerPage;
  final List<int> availableRowsPerPage;
  final void Function(int?)? onRowsPerPageChanged;
  final int? currentPage;
  final int? totalPages;
  final void Function(int)? onPageChanged;
  final void Function(int)? onRowTap;
  final List<T>? selectedItems;
  final void Function(bool?, T)? onSelectChanged;
  final bool sortAscending;
  final int? sortColumnIndex;
  final void Function(int, bool)? onSort;
  
  const MasterDataTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.dataRowBuilder,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
    this.minWidth,
    this.maxHeight,
    this.showCheckboxColumn = false,
    this.showFirstLastButtons = true,
    this.showPageSizeSelector = true,
    this.rowsPerPage,
    this.availableRowsPerPage = const [10, 20, 50, 100],
    this.onRowsPerPageChanged,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
    this.onRowTap,
    this.selectedItems,
    this.onSelectChanged,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth ?? 600,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: DataTable2(
              columns: columns,
              rows: List.generate(
                data.length,
                (index) => dataRowBuilder(data[index], index),
              ),
              minWidth: minWidth,
              showCheckboxColumn: showCheckboxColumn,
              sortAscending: sortAscending,
              sortColumnIndex: sortColumnIndex,
              onSelectAll: showCheckboxColumn && onSelectChanged != null
                  ? (value) {
                      if (value == true) {
                        for (var item in data) {
                          if (selectedItems == null || !selectedItems!.contains(item)) {
                            onSelectChanged!(true, item);
                          }
                        }
                      } else {
                        for (var item in data) {
                          if (selectedItems != null && selectedItems!.contains(item)) {
                            onSelectChanged!(false, item);
                          }
                        }
                      }
                    }
                  : null,
            ),
          ),
        ),
        if (rowsPerPage != null && onPageChanged != null && totalPages != null && currentPage != null)
          _buildPagination(context),
      ],
    );
  }
  
  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showPageSizeSelector && onRowsPerPageChanged != null)
            Row(
              children: [
                Text(
                  'Rows per page:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: rowsPerPage,
                  items: availableRowsPerPage.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: onRowsPerPageChanged,
                  underline: Container(),
                ),
              ],
            )
          else
            const SizedBox(),
          Row(
            children: [
              Text(
                'Page ${currentPage! + 1} of $totalPages',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              if (showFirstLastButtons)
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: currentPage! > 0
                      ? () => onPageChanged!(0)
                      : null,
                  tooltip: 'First page',
                ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage! > 0
                    ? () => onPageChanged!(currentPage! - 1)
                    : null,
                tooltip: 'Previous page',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage! < totalPages! - 1
                    ? () => onPageChanged!(currentPage! + 1)
                    : null,
                tooltip: 'Next page',
              ),
              if (showFirstLastButtons)
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: currentPage! < totalPages! - 1
                      ? () => onPageChanged!(totalPages! - 1)
                      : null,
                  tooltip: 'Last page',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MasterDataTableActions extends StatelessWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onExport;
  final VoidCallback? onImport;
  final VoidCallback? onPrint;
  final VoidCallback? onDelete;
  final bool showAdd;
  final bool showRefresh;
  final bool showExport;
  final bool showImport;
  final bool showPrint;
  final bool showDelete;
  final bool isDeleteEnabled;
  
  const MasterDataTableActions({
    Key? key,
    this.onAdd,
    this.onRefresh,
    this.onExport,
    this.onImport,
    this.onPrint,
    this.onDelete,
    this.showAdd = true,
    this.showRefresh = true,
    this.showExport = true,
    this.showImport = false,
    this.showPrint = true,
    this.showDelete = false,
    this.isDeleteEnabled = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showAdd)
          Tooltip(
            message: 'Add',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (showRefresh)
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (showExport)
          Tooltip(
            message: 'Export',
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: onExport,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (showImport)
          Tooltip(
            message: 'Import',
            child: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: onImport,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (showPrint)
          Tooltip(
            message: 'Print',
            child: IconButton(
              icon: const Icon(Icons.print),
              onPressed: onPrint,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (showDelete)
          Tooltip(
            message: 'Delete',
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: isDeleteEnabled ? onDelete : null,
              color: isDeleteEnabled ? AppColors.errorColor : Theme.of(context).disabledColor,
            ),
          ),
      ],
    );
  }
}

class MasterDataTableHeader extends StatelessWidget {
  final String title;
  final Widget? actions;
  final Widget? searchField;
  final bool showDivider;
  
  const MasterDataTableHeader({
    Key? key,
    required this.title,
    this.actions,
    this.searchField,
    this.showDivider = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (searchField != null)
                Expanded(
                  flex: 2,
                  child: searchField!,
                ),
              if (actions != null)
                actions!,
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: Theme.of(context).dividerColor,
            height: 1,
          ),
      ],
    );
  }
}

