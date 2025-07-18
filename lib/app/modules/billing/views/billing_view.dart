import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/billing_controller.dart';

class BillingView extends GetView<BillingController> {
  const BillingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
      ),
      body: Center(
        child: Text(
          'Billing View - Under Construction',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

