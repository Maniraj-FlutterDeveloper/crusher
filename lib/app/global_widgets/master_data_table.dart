import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../core/values/app_colors.dart';
import 'custom_form_field.dart';

class MasterDataTable<T> extends StatelessWidget {
  final List<DataColumn2> columns;
  final List<T> data;
  final List<DataRow> Function(List<T>) rowBuilder;
  final String title;
  final VoidCallback onAdd;
  final void Function(String) onSearch;
  final bool isLoading;
  final String? emptyMessage;
  final TextEditingController searchController;
  final Widget? customActions;
  final bool showSearch;
  final bool showAddButton;
  final String? addButtonLabel;
  final IconData? addButtonIcon;

  const MasterDataTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.rowBuilder,
    required this.title,
    required this.onAdd,
    required this.onSearch,
    required this.searchController,
    this.isLoading = false,
    this.emptyMessage,
    this.customActions,
    this.showSearch = true,
    this.showAddButton = true,
    this.addButtonLabel,
    this.addButtonIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 16),
            Expanded(
              child: _buildTable(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Spacer(),
        if (showSearch)
          Container(
            width: 300,
            child: CustomSearchField(
              controller: searchController,
              hint: 'Search $title',
              onChanged: onSearch,
              onClear: () => onSearch(''),
            ),
          ),
        SizedBox(width: 16),
        if (customActions != null) customActions!,
        if (showAddButton)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: Icon(addButtonIcon ?? Icons.add),
            label: Text(addButtonLabel ?? 'Add New'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppColors.textLightColor,
            ),
            SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No data found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textLightColor,
                  ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add),
              label: Text('Add New'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DataTable2(
      columns: columns,
      rows: rowBuilder(data),
      dividerThickness: 1,
      dataRowHeight: 60,
      headingRowHeight: 60,
      horizontalMargin: 16,
      minWidth: 600,
      showCheckboxColumn: false,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      headingRowColor: MaterialStateProperty.all(
        AppColors.primaryColor.withOpacity(0.1),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

