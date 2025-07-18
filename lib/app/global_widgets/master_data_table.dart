import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../core/values/app_colors.dart';

class MasterDataTableHeader extends StatelessWidget {
  final String title;
  final Widget searchField;
  final Widget actions;
  
  const MasterDataTableHeader({
    Key? key,
    required this.title,
    required this.searchField,
    required this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              actions,
            ],
          ),
          const SizedBox(height: 16),
          searchField,
        ],
      ),
    );
  }
}

class MasterDataTableActions extends StatelessWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onExport;
  final VoidCallback? onPrint;
  final VoidCallback? onDelete;
  final bool showDelete;
  
  const MasterDataTableActions({
    Key? key,
    this.onAdd,
    this.onRefresh,
    this.onExport,
    this.onPrint,
    this.onDelete,
    this.showDelete = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
            tooltip: 'Add',
          ),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        if (onExport != null)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onExport,
            tooltip: 'Export',
          ),
        if (onPrint != null)
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: onPrint,
            tooltip: 'Print',
          ),
        if (showDelete && onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
      ],
    );
  }
}

class MasterDataTable<T> extends StatelessWidget {
  final List<DataColumn2> columns;
  final List<T> data;
  final DataRow2 Function(T item, int index) dataRowBuilder;
  final bool isLoading;
  final String emptyMessage;
  final bool showCheckboxColumn;
  final bool sortAscending;
  final int? sortColumnIndex;
  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final void Function(int?)? onRowsPerPageChanged;
  final int currentPage;
  final int totalPages;
  final void Function(int)? onPageChanged;
  
  const MasterDataTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.dataRowBuilder,
    this.isLoading = false,
    this.emptyMessage = 'No data found',
    this.showCheckboxColumn = false,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.rowsPerPage = 10,
    this.availableRowsPerPage = const [10, 20, 50, 100],
    this.onRowsPerPageChanged,
    this.currentPage = 0,
    this.totalPages = 1,
    this.onPageChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: DataTable2(
            columns: columns,
            rows: data.asMap().entries.map((entry) => dataRowBuilder(entry.value, entry.key)).toList(),
            showCheckboxColumn: showCheckboxColumn,
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            empty: Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dividerThickness: 1,
            dataRowHeight: 56,
            headingRowHeight: 56,
            horizontalMargin: 16,
            columnSpacing: 16,
          ),
        ),
        _buildPagination(),
      ],
    );
  }
  
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (onRowsPerPageChanged != null)
            Row(
              children: [
                const Text('Rows per page:'),
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
                ),
              ],
            ),
          const Spacer(),
          if (onPageChanged != null)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: currentPage > 0 ? () => onPageChanged!(0) : null,
                  tooltip: 'First Page',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 0 ? () => onPageChanged!(currentPage - 1) : null,
                  tooltip: 'Previous Page',
                ),
                Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages - 1 ? () => onPageChanged!(currentPage + 1) : null,
                  tooltip: 'Next Page',
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: currentPage < totalPages - 1 ? () => onPageChanged!(totalPages - 1) : null,
                  tooltip: 'Last Page',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

