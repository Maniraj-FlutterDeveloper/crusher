import 'package:crusher_management/app/data/models/material_size_model.dart';
import 'package:crusher_management/app/data/models/weighbridge_record_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../data/models/material_model.dart';
import '../../controllers/billing_controller.dart';

class InvoiceItemForm extends GetView<BillingController> {
  final InvoiceItemModel? item;
  final Function(InvoiceItemModel) onSave;
  final VoidCallback onCancel;

  const InvoiceItemForm({
    Key? key,
    this.item,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    
    // Form state
    final materialRx = Rx<MaterialModel?>(item?.material);
    final materialSizeRx = Rx<MaterialSizeModel?>(item?.materialSize);
    final weightUnitRx = Rx<WeightUnitModel?>(item?.weightUnit);
    final quantityRx = Rx<double>(item?.quantity ?? 0);
    final rateRx = Rx<double>(item?.rate ?? 0);
    final cgstPercentageRx = Rx<double>(item?.cgstPercentage ?? 0);
    final sgstPercentageRx = Rx<double>(item?.sgstPercentage ?? 0);
    final igstPercentageRx = Rx<double>(item?.igstPercentage ?? 0);
    
    // Controllers
    final quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );
    final rateController = TextEditingController(
      text: item?.rate.toString() ?? '',
    );
    
    // Calculate amounts
    void calculateAmounts() {
      final quantity = quantityRx.value;
      final rate = rateRx.value;
      
      if (quantity > 0 && rate > 0) {
        final amount = quantity * rate;
        
        if (controller.isSameState.value) {
          final cgstAmount = amount * (cgstPercentageRx.value / 100);
          final sgstAmount = amount * (sgstPercentageRx.value / 100);
          final totalAmount = amount + cgstAmount + sgstAmount;
          
          // Update UI
          cgstAmountController.text = cgstAmount.toStringAsFixed(2);
          sgstAmountController.text = sgstAmount.toStringAsFixed(2);
          igstAmountController.text = '0.00';
          totalAmountController.text = totalAmount.toStringAsFixed(2);
        } else {
          final igstAmount = amount * (igstPercentageRx.value / 100);
          final totalAmount = amount + igstAmount;
          
          // Update UI
          cgstAmountController.text = '0.00';
          sgstAmountController.text = '0.00';
          igstAmountController.text = igstAmount.toStringAsFixed(2);
          totalAmountController.text = totalAmount.toStringAsFixed(2);
        }
        
        // Update amount
        amountController.text = amount.toStringAsFixed(2);
      }
    }
    
    // Update tax percentages when material changes
    void updateTaxPercentages() {
      if (materialRx.value != null) {
        final material = materialRx.value!;
        
        if (material.taxConfiguration != null) {
          cgstPercentageRx.value = material.taxConfiguration!.cgstPercentage;
          sgstPercentageRx.value = material.taxConfiguration!.sgstPercentage;
          igstPercentageRx.value = material.taxConfiguration!.igstPercentage;
          
          // Update UI
          cgstPercentageController.text = cgstPercentageRx.value.toString();
          sgstPercentageController.text = sgstPercentageRx.value.toString();
          igstPercentageController.text = igstPercentageRx.value.toString();
          
          // Update rate
          rateRx.value = material.rate ?? 0;
          rateController.text = rateRx.value.toString();
          
          // Recalculate amounts
          calculateAmounts();
        }
      }
    }
    
    // Additional controllers for display only
    final amountController = TextEditingController(
      text: item?.amount.toStringAsFixed(2) ?? '0.00',
    );
    final cgstPercentageController = TextEditingController(
      text: item?.cgstPercentage.toString() ?? '0',
    );
    final sgstPercentageController = TextEditingController(
      text: item?.sgstPercentage.toString() ?? '0',
    );
    final igstPercentageController = TextEditingController(
      text: item?.igstPercentage.toString() ?? '0',
    );
    final cgstAmountController = TextEditingController(
      text: item?.cgstAmount.toStringAsFixed(2) ?? '0.00',
    );
    final sgstAmountController = TextEditingController(
      text: item?.sgstAmount.toStringAsFixed(2) ?? '0.00',
    );
    final igstAmountController = TextEditingController(
      text: item?.igstAmount.toStringAsFixed(2) ?? '0.00',
    );
    final totalAmountController = TextEditingController(
      text: item?.totalAmount.toStringAsFixed(2) ?? '0.00',
    );
    
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item == null ? 'Add Invoice Item' : 'Edit Invoice Item',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<MaterialModel>(
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        border: OutlineInputBorder(),
                      ),
                      value: materialRx.value,
                      onChanged: (value) {
                        if (value != null) {
                          materialRx.value = value;
                          
                          // Reset material size when material changes
                          materialSizeRx.value = null;
                          
                          // Update tax percentages
                          updateTaxPercentages();
                        }
                      },
                      items: controller.materials
                          .map((material) => DropdownMenuItem<MaterialModel>(
                                value: material,
                                child: Text(material.name),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a material';
                        }
                        return null;
                      },
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<MaterialSizeModel>(
                      decoration: const InputDecoration(
                        labelText: 'Size',
                        border: OutlineInputBorder(),
                      ),
                      value: materialSizeRx.value,
                      onChanged: (value) {
                        if (value != null) {
                          materialSizeRx.value = value;
                        }
                      },
                      items: controller.materialSizes
                          .map((size) => DropdownMenuItem<MaterialSizeModel>(
                                value: size,
                                child: Text(size.name),
                              ))
                          .toList(),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      quantityRx.value = double.tryParse(value) ?? 0;
                      calculateAmounts();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    
                    final quantity = double.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => DropdownButtonFormField<WeightUnitModel>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: weightUnitRx.value,
                      onChanged: (value) {
                        if (value != null) {
                          weightUnitRx.value = value;
                        }
                      },
                      items: controller.weightUnits
                          .map((unit) => DropdownMenuItem<WeightUnitModel>(
                                value: unit,
                                child: Text(unit.name),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a unit';
                        }
                        return null;
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(
                    labelText: 'Rate (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      rateRx.value = double.tryParse(value) ?? 0;
                      calculateAmounts();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rate';
                    }
                    
                    final rate = double.tryParse(value);
                    if (rate == null || rate <= 0) {
                      return 'Please enter a valid rate';
                    }
                    
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tax Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.isSameState.value) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cgstPercentageController,
                          decoration: const InputDecoration(
                            labelText: 'CGST %',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cgstAmountController,
                          decoration: const InputDecoration(
                            labelText: 'CGST Amount (₹)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: sgstPercentageController,
                          decoration: const InputDecoration(
                            labelText: 'SGST %',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: sgstAmountController,
                          decoration: const InputDecoration(
                            labelText: 'SGST Amount (₹)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: igstPercentageController,
                      decoration: const InputDecoration(
                        labelText: 'IGST %',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: igstAmountController,
                      decoration: const InputDecoration(
                        labelText: 'IGST Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              );
            }
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                child: TextFormField(
                  controller: totalAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Create invoice item
                    final newItem = InvoiceItemModel(
                      invoiceId: item?.invoiceId ?? 0,
                      materialId: materialRx.value!.id!,
                      materialSizeId: materialSizeRx.value?.id,
                      quantity: quantityRx.value,
                      weightUnitId: weightUnitRx.value!.id!,
                      rate: rateRx.value,
                      amount: double.parse(amountController.text),
                      cgstPercentage: cgstPercentageRx.value,
                      sgstPercentage: sgstPercentageRx.value,
                      igstPercentage: igstPercentageRx.value,
                      cgstAmount: double.parse(cgstAmountController.text),
                      sgstAmount: double.parse(sgstAmountController.text),
                      igstAmount: double.parse(igstAmountController.text),
                      totalAmount: double.parse(totalAmountController.text),
                      createdAt: item?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                      material: materialRx.value,
                      materialSize: materialSizeRx.value,
                      weightUnit: weightUnitRx.value,
                    );
                    
                    onSave(newItem);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

