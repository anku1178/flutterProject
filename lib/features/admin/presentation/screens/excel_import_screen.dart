import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';

class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  State<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  String? _selectedFileName;
  bool _isUploading = false;
  bool _hasValidated = false;
  List<Map<String, dynamic>> _previewData = [];
  final List<String> _requiredColumns = [
    'name',
    'description',
    'price',
    'stock',
    'category',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Import Products from Excel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Import Instructions',
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please ensure your Excel file contains the following columns:',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 12),
                    ..._requiredColumns.map((column) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                column.toUpperCase(),
                                style: AppTextStyles.body2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supported file formats:',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '.xlsx, .xls, .csv',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Download Template
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download Template',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download our Excel template to ensure your file has the correct format.',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: 'Download Template',
                      icon: Icons.download,
                      onPressed: _downloadTemplate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Upload
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload File',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 16),

                    // File Upload Area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFileName != null
                              ? AppColors.success
                              : AppColors.borderColor,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedFileName != null
                            ? AppColors.success.withOpacity(0.05)
                            : AppColors.surface,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFileName != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            size: 48,
                            color: _selectedFileName != null
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFileName ??
                                'Click to select your Excel file',
                            style: AppTextStyles.subtitle2.copyWith(
                              color: _selectedFileName != null
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedFileName == null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'or drag and drop here',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: _selectedFileName != null
                                ? 'Change File'
                                : 'Select File',
                            icon: Icons.folder_open,
                            onPressed: _selectFile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedFileName != null) ...[
              const SizedBox(height: 24),

              // Validation & Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Validation & Preview',
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 16),
                      if (!_hasValidated) ...[
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.rule,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Validate your file to check for errors',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 16),
                              SecondaryButton(
                                text: 'Validate File',
                                icon: Icons.verified,
                                onPressed: _validateFile,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Validation Results
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'File validated successfully! Found ${_previewData.length} products.',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Preview Data
                        if (_previewData.isNotEmpty) ...[
                          Text(
                            'Preview (First 5 rows)',
                            style: AppTextStyles.subtitle2,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: _requiredColumns.map((column) {
                                  return DataColumn(
                                    label: Text(
                                      column.toUpperCase(),
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                rows: _previewData.take(5).map((row) {
                                  return DataRow(
                                    cells: _requiredColumns.map((column) {
                                      return DataCell(
                                        Text(
                                          row[column]?.toString() ?? '',
                                          style: AppTextStyles.caption,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],

            if (_hasValidated && _previewData.isNotEmpty) ...[
              const SizedBox(height: 24),

              // Import Button
              PrimaryButton(
                text: _isUploading ? 'Importing...' : 'Import Products',
                icon: _isUploading ? null : Icons.upload,
                onPressed: _isUploading ? null : _importProducts,
                isLoading: _isUploading,
                width: double.infinity,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFileName = result.files.first.name;
          _hasValidated = false;
          _previewData.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _validateFile() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate file validation
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock preview data
    _previewData = List.generate(
        10,
        (index) => {
              'name': 'Product ${index + 1}',
              'description': 'Description for product ${index + 1}',
              'price': '${(index + 1) * 10}.99',
              'stock': '${(index + 1) * 5}',
              'category': ['Groceries', 'Electronics', 'Clothing'][index % 3],
            });

    setState(() {
      _hasValidated = true;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File validated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _importProducts() async {
    setState(() {
      _isUploading = true;
    });

    // Simulate import process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isUploading = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            const Text('Import Successful'),
          ],
        ),
        content: Text(
          'Successfully imported ${_previewData.length} products!\n\nYou can now view and manage them in the inventory section.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('View Inventory'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Import More'),
          ),
        ],
      ),
    );
  }

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template download started'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
