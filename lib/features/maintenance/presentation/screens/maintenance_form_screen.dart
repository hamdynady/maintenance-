import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:maintenance2/core/services/maintenance_service.dart';
import 'package:intl/intl.dart';

class MaintenanceFormScreen extends StatefulWidget {
  final Map<String, dynamic>? maintenanceRecord;
  const MaintenanceFormScreen({super.key, this.maintenanceRecord});

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _maintenanceService = MaintenanceService();
  File? _reportImage;
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _subProducts = [];
  List<Map<String, dynamic>> _models = [];
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isDisposed = false;

  final List<String> _statusOptions = ['قيد المعالجة', 'مكتمل', 'ملغي'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _addressController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void _setStateIfMounted(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadInitialData() async {
    if (_isDisposed) return;
    _setStateIfMounted(() => _isLoading = true);
    try {
      await _loadBrands();
      if (widget.maintenanceRecord != null) {
        await _loadExistingData();
      }
    } finally {
      if (!_isDisposed) {
        _setStateIfMounted(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadExistingData() async {
    if (_isDisposed) return;
    final record = widget.maintenanceRecord!;
    if (record['brand_id'] != null) {
      await _loadProducts(record['brand_id']);
    }
    if (record['product_id'] != null) {
      await _loadSubProducts(record['product_id']);
    }
    if (record['sub_product_id'] != null) {
      await _loadModels(record['sub_product_id']);
    }
  }

  Future<void> _loadBrands() async {
    if (_isDisposed) return;
    try {
      final brands = await _maintenanceService.getBrands();
      if (!_isDisposed) {
        _setStateIfMounted(() {
          _brands = brands;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading brands: $e')),
        );
      }
    }
  }

  Future<void> _loadProducts(int brandId) async {
    if (_isDisposed) return;
    _setStateIfMounted(() => _isLoading = true);
    try {
      final products = await _maintenanceService.getProducts(brandId);
      if (!_isDisposed) {
        _setStateIfMounted(() {
          _products = products;
          _subProducts = [];
          _models = [];
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    } finally {
      if (!_isDisposed) {
        _setStateIfMounted(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSubProducts(int productId) async {
    if (_isDisposed) return;
    _setStateIfMounted(() => _isLoading = true);
    try {
      final subProducts = await _maintenanceService.getSubProducts(productId);
      if (!_isDisposed) {
        _setStateIfMounted(() {
          _subProducts = subProducts;
          _models = [];
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sub-products: $e')),
        );
      }
    } finally {
      if (!_isDisposed) {
        _setStateIfMounted(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadModels(int subProductId) async {
    if (_isDisposed) return;
    _setStateIfMounted(() => _isLoading = true);
    try {
      final models = await _maintenanceService.getModels(subProductId);
      if (!_isDisposed) {
        _setStateIfMounted(() {
          _models = models;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading models: $e')),
        );
      }
    } finally {
      if (!_isDisposed) {
        _setStateIfMounted(() => _isLoading = false);
      }
    }
  }

  Future<void> _onModelSelected(int modelId) async {
    if (_isDisposed) return;
    _setStateIfMounted(() => _isLoading = true);
    try {
      final modelDetails = await _maintenanceService.getModelDetails(modelId);
      if (modelDetails != null && !_isDisposed && mounted) {
        _formKey.currentState?.fields['arabic_name']
            ?.didChange(modelDetails['arabic_description']);
        _formKey.currentState?.fields['english_name']
            ?.didChange(modelDetails['english_description']);
        _formKey.currentState?.fields['manufacturer']
            ?.didChange(modelDetails['manufacturer']);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading model details: $e')),
        );
      }
    } finally {
      if (!_isDisposed) {
        _setStateIfMounted(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    if (_isDisposed) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null && !_isDisposed) {
      _setStateIfMounted(() {
        _reportImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isDisposed) return;
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      if (formData == null) return;

      final maintenanceService = MaintenanceService();
      final maintenanceRecord = Map<String, dynamic>.from({
        'phone_number': formData['phone_number'],
        'name': formData['name'],
        'address': formData['address'],
        'brand_id': int.parse(formData['brand_id']),
        'product_id': int.parse(formData['product_id']),
        'sub_product_id': int.parse(formData['sub_product_id']),
        'model_id': int.parse(formData['model_id']),
        'maintenance_date': formData['maintenance_date'].toString(),
        'status': formData['status'],
        'spare_parts': formData['spare_parts'] ?? '',
        'report': formData['report'] ?? '',
        'arabic_name': formData['arabic_name'],
        'english_name': formData['english_name'],
        'manufacturer': formData['manufacturer'],
      });

      try {
        if (widget.maintenanceRecord != null) {
          maintenanceRecord['id'] = widget.maintenanceRecord!['id'];
          await maintenanceService.updateMaintenanceRecord(
            id: maintenanceRecord['id'],
            phoneNumber: maintenanceRecord['phone_number'],
            name: maintenanceRecord['name'],
            address: maintenanceRecord['address'],
            brandId: maintenanceRecord['brand_id'],
            productId: maintenanceRecord['product_id'],
            subProductId: maintenanceRecord['sub_product_id'],
            modelId: maintenanceRecord['model_id'],
            maintenanceDate:
                DateTime.parse(maintenanceRecord['maintenance_date']),
            status: maintenanceRecord['status'],
            spareParts: maintenanceRecord['spare_parts'],
            report: maintenanceRecord['report'],
            arabicName: maintenanceRecord['arabic_name'],
            englishName: maintenanceRecord['english_name'],
            manufacturer: maintenanceRecord['manufacturer'],
            reportImage: _reportImage,
          );
        } else {
          await maintenanceService.createMaintenanceRecord(
            phoneNumber: maintenanceRecord['phone_number'],
            name: maintenanceRecord['name'],
            address: maintenanceRecord['address'],
            brandId: maintenanceRecord['brand_id'],
            productId: maintenanceRecord['product_id'],
            subProductId: maintenanceRecord['sub_product_id'],
            modelId: maintenanceRecord['model_id'],
            maintenanceDate:
                DateTime.parse(maintenanceRecord['maintenance_date']),
            status: maintenanceRecord['status'],
            spareParts: maintenanceRecord['spare_parts'],
            report: maintenanceRecord['report'],
            arabicName: maintenanceRecord['arabic_name'],
            englishName: maintenanceRecord['english_name'],
            manufacturer: maintenanceRecord['manufacturer'],
            reportImage: _reportImage,
          );
        }

        if (!_isDisposed && mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving maintenance record: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.maintenanceRecord != null
              ? 'تعديل الصيانة'
              : 'إضافة طلب صيانة جديد',
        ),
        centerTitle: true,
        actions: widget.maintenanceRecord != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(),
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _formKey,
              initialValue: widget.maintenanceRecord != null
                  ? {
                      'phone_number': widget.maintenanceRecord!['phone_number'],
                      'name': widget.maintenanceRecord!['name'],
                      'address': widget.maintenanceRecord!['address'],
                      'brand_id':
                          widget.maintenanceRecord!['brand_id']?.toString(),
                      'product_id':
                          widget.maintenanceRecord!['product_id']?.toString(),
                      'sub_product_id': widget
                          .maintenanceRecord!['sub_product_id']
                          ?.toString(),
                      'model_id':
                          widget.maintenanceRecord!['model_id']?.toString(),
                      'maintenance_date': DateTime.parse(
                        widget.maintenanceRecord!['maintenance_date'],
                      ),
                      'status':
                          widget.maintenanceRecord!['status'] ?? 'قيد المعالجة',
                      'spare_parts': widget.maintenanceRecord!['spare_parts'],
                      'report': widget.maintenanceRecord!['report'],
                      'arabic_name': widget.maintenanceRecord!['arabic_name'],
                      'english_name': widget.maintenanceRecord!['english_name'],
                      'manufacturer': widget.maintenanceRecord!['manufacturer'],
                    }
                  : {
                      'status': 'قيد المعالجة',
                    },
              child: Column(
                children: [
                  // Phone Number
                  FormBuilderTextField(
                    name: 'phone_number',
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  FormBuilderTextField(
                    name: 'address',
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      hintText: 'أدخل العنوان',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Brand Selection
                  FormBuilderDropdown(
                    name: 'brand_id',
                    decoration: const InputDecoration(
                      labelText: 'العلامة التجارية',
                      border: OutlineInputBorder(),
                    ),
                    items: _brands.isEmpty
                        ? [
                            const DropdownMenuItem(
                                value: null, child: Text('جاري التحميل...'))
                          ]
                        : _brands
                            .map(
                              (brand) => DropdownMenuItem(
                                value: brand['id'].toString(),
                                child: Text(brand['name']),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _loadProducts(int.parse(value));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Product Selection
                  FormBuilderDropdown(
                    name: 'product_id',
                    decoration: const InputDecoration(
                      labelText: 'المنتج',
                      border: OutlineInputBorder(),
                    ),
                    items: _products.isEmpty
                        ? [
                            const DropdownMenuItem(
                                value: null, child: Text('جاري التحميل...'))
                          ]
                        : _products
                            .map(
                              (product) => DropdownMenuItem(
                                value: product['id'].toString(),
                                child: Text(product['name']),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _loadSubProducts(int.parse(value));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Sub-Product Selection
                  FormBuilderDropdown(
                    name: 'sub_product_id',
                    decoration: const InputDecoration(
                      labelText: 'النوع',
                      border: OutlineInputBorder(),
                    ),
                    items: _subProducts.isEmpty
                        ? [
                            const DropdownMenuItem(
                                value: null, child: Text('جاري التحميل...'))
                          ]
                        : _subProducts
                            .map(
                              (subProduct) => DropdownMenuItem(
                                value: subProduct['id'].toString(),
                                child: Text(subProduct['name']),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _loadModels(int.parse(value));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Model Selection
                  FormBuilderDropdown(
                    name: 'model_id',
                    decoration: const InputDecoration(
                      labelText: 'الموديل',
                      border: OutlineInputBorder(),
                    ),
                    items: _models.isEmpty
                        ? [
                            const DropdownMenuItem(
                                value: null, child: Text('جاري التحميل...'))
                          ]
                        : _models
                            .map(
                              (model) => DropdownMenuItem(
                                value: model['id'].toString(),
                                child: Text(model['name']),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _onModelSelected(int.parse(value));
                      }
                    },
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Arabic Name
                  FormBuilderTextField(
                    name: 'arabic_name',
                    decoration: const InputDecoration(
                      labelText: 'الاسم بالعربية',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // English Name
                  FormBuilderTextField(
                    name: 'english_name',
                    decoration: const InputDecoration(
                      labelText: 'الاسم بالإنجليزية',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Manufacturer
                  FormBuilderTextField(
                    name: 'manufacturer',
                    decoration: const InputDecoration(
                      labelText: 'المصنع',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Status Selection
                  FormBuilderDropdown(
                    name: 'status',
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    initialValue: widget.maintenanceRecord != null
                        ? widget.maintenanceRecord!['status'] ?? 'قيد المعالجة'
                        : 'قيد المعالجة',
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Spare Parts
                  FormBuilderTextField(
                    name: 'spare_parts',
                    decoration: const InputDecoration(
                      labelText: 'قطع الغيار',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Report
                  FormBuilderTextField(
                    name: 'report',
                    decoration: const InputDecoration(
                      labelText: 'التقرير',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Maintenance Date
                  FormBuilderDateTimePicker(
                    name: 'maintenance_date',
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الصيانة',
                      border: OutlineInputBorder(),
                    ),
                    inputType: InputType.date,
                    format: DateFormat('yyyy-MM-dd'),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Report Image Section
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(fromCamera: true),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('التقاط صورة'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(fromCamera: false),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('اختيار من المعرض'),
                          ),
                        ],
                      ),
                      if (_reportImage != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            Image.file(
                              _reportImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _reportImage = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      widget.maintenanceRecord != null
                          ? 'تحديث الصيانة'
                          : 'إضافة طلب الصيانة',
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    if (_isDisposed) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الصيانة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMaintenance();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMaintenance() async {
    if (_isDisposed) return;
    try {
      final maintenanceService = MaintenanceService();
      await maintenanceService
          .deleteMaintenanceRecord(widget.maintenanceRecord!['id']);
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الصيانة بنجاح')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting maintenance record: $e')),
        );
      }
    }
  }
}
