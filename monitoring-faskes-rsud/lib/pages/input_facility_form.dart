// pages/input_facility_form.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/facilities_page.dart';
import 'package:monitoring_faskes_rsud/services/api_service.dart';

import '../models/input_facility_model.dart';

class InputFacilityForm extends StatefulWidget {
  const InputFacilityForm({super.key});

  @override
  State<InputFacilityForm> createState() => _InputFacilityFormState();
}

class _InputFacilityFormState extends State<InputFacilityForm> {
  final _formKey = GlobalKey<FormState>();

  final nameFacilityController = TextEditingController();

  final totalUnitController = TextEditingController();

  final usedUnitController = TextEditingController();

  final noteController = TextEditingController();

  bool isLoading = false;

  int? selectedFacilityType;

  final List<Map<String, dynamic>> facilityTypes = [
    {"id": 1, "name": "ICU"},
    {"id": 2, "name": "NICU"},
    {"id": 3, "name": "HCU"},
    {"id": 4, "name": "ICCU"},
    {"id": 5, "name": "PICU"},
    {"id": 6, "name": "UGD"},
  ];

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = InputFacilityModel(
        nameFacility: nameFacilityController.text,
        totalUnit: int.parse(totalUnitController.text),
        note: noteController.text,
      );

      final response = await ApiService.storeFacility(data);

      setState(() {
        isLoading = false;
      });

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["data"]["message"] ?? "Berhasil disimpan"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["data"]["message"] ?? "Gagal menyimpan"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),

        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FacilitiesPage()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),

        centerTitle: true,

        title: const Text(
          "Tambah Fasilitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FB),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  buildLabel("Nama Fisilitas"),

                  TextFormField(
                    controller: nameFacilityController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration("Masukkan Nama Fasilitas"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nama fasilitas wajib diisi";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // TOTAL UNIT
                  buildLabel("Total Unit"),

                  TextFormField(
                    controller: totalUnitController,
                    keyboardType: TextInputType.number,
                    decoration: inputDecoration("Masukkan total unit"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Total unit wajib diisi";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // NOTE
                  buildLabel("Catatan (Opsional)"),

                  TextFormField(
                    controller: noteController,
                    maxLines: 5,
                    decoration: inputDecoration("Tambahkan catatan..."),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitData,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Simpan Fasilitas",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
