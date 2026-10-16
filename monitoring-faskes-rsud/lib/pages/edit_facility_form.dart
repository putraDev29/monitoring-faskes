// pages/edit_facility_form.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/facilities_page.dart';

import '../models/facility_model.dart';
import '../services/api_service.dart';

class EditFacilityForm extends StatefulWidget {
  final Facility facility;

  const EditFacilityForm({super.key, required this.facility});

  @override
  State<EditFacilityForm> createState() => _EditFacilityFormState();
}

class _EditFacilityFormState extends State<EditFacilityForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController totalUnitController;
  late TextEditingController usedUnitController;
  late TextEditingController availableUnitController;
  late TextEditingController percentageController;
  late TextEditingController noteController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    totalUnitController = TextEditingController(
      text: widget.facility.totalUnit.toString(),
    );

    usedUnitController = TextEditingController(
      text: widget.facility.usedUnit.toString(),
    );

    availableUnitController = TextEditingController(
      text: widget.facility.availableUnit.toString(),
    );

    percentageController = TextEditingController(
      text: "${widget.facility.percentage}%",
    );

    noteController = TextEditingController(text: widget.facility.note);
  }

  void calculateData() {
    final total = int.tryParse(totalUnitController.text) ?? 0;

    final used = int.tryParse(usedUnitController.text) ?? 0;

    int available = total - used;

    if (available < 0) {
      available = 0;
    }

    double percentage = 0;

    if (total > 0) {
      percentage = (available / total) * 100;
    }

    availableUnitController.text = available.toString();

    // FIX: gunakan percentageController, bukan availableUnitController
    percentageController.text = "${percentage.toStringAsFixed(2)}%";
  }

  Future<void> submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = EditFacilityModel(
        totalUnit: int.parse(totalUnitController.text),
        usedUnit: int.parse(usedUnitController.text),
        note: noteController.text,
      );

      final response = await ApiService.updateFacility(
        widget.facility.id,
        data,
      );

      setState(() {
        isLoading = false;
      });

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["data"]["message"] ?? "Berhasil update"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["data"]["message"] ?? "Gagal update"),
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

  Color getStatusColor(String status) {
    switch (status) {
      case "safe":
        return Colors.green;

      case "warning":
        return Colors.orange;

      case "critical":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData getIcon(String icon) {
    switch (icon) {
      case 'baby':
        return Icons.child_care;

      case 'activity':
        return Icons.monitor_heart;

      case 'heart':
        return Icons.favorite;

      case 'stethoscope':
        return Icons.medical_services;

      case 'hospital':
        return Icons.local_hospital;

      case 'home':
        return Icons.home;

      case 'shield':
        return Icons.shield;

      case 'scissors':
        return Icons.content_cut;

      case 'plus':
        return Icons.add;

      default:
        return Icons.medical_information;
    }
  }

  Color getCardColor(String color) {
    switch (color) {
      case 'blue':
        return Colors.blue;

      case 'green':
        return Colors.green;

      case 'orange':
        return Colors.orange;

      case 'purple':
        return Colors.purple;

      case 'cyan':
        return Colors.cyan;

      case 'lime':
        return Colors.lime;

      case 'yellow':
        return Colors.amber;

      case 'pink':
        return Colors.pink;

      case 'indigo':
        return Colors.indigo;

      default:
        return Colors.grey;
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          title,

          textAlign: TextAlign.left,

          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilityType = widget.facility.facilityType;

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // biru untuk area di balik lengkungan

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
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

        title: const Text(
          "Edit Fasilitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      // Body melengkung di bagian atas
      body: Container(
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: getCardColor(
                            facilityType.color,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          getIcon(facilityType.icon),
                          color: getCardColor(facilityType.color),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facilityType.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            facilityType.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Informasi Unit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                buildLabel("Total Unit"),

                TextFormField(
                  controller: totalUnitController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => calculateData(),
                  decoration: inputDecoration(""),
                ),

                const SizedBox(height: 18),

                buildLabel("Terpakai"),

                TextFormField(
                  controller: usedUnitController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => calculateData(),
                  decoration: inputDecoration(""),
                ),

                const SizedBox(height: 18),

                buildLabel("Tersedia"),

                TextFormField(
                  readOnly: true,
                  controller: availableUnitController,
                  style: const TextStyle(color: Colors.black54),
                  decoration: inputDecoration(
                    "",
                  ).copyWith(filled: true, fillColor: Colors.grey.shade200),
                ),

                const SizedBox(height: 18),

                buildLabel("Persentase"),

                // FIX: gunakan percentageController, bukan availableUnitController
                TextFormField(
                  readOnly: true,
                  controller: percentageController,
                  style: const TextStyle(color: Colors.black54),
                  decoration: inputDecoration(
                    "",
                  ).copyWith(filled: true, fillColor: Colors.grey.shade200),
                ),

                const SizedBox(height: 18),

                buildLabel("Catatan (Opsional)"),

                TextFormField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: inputDecoration(
                    "Tambahkan catatan jika diperlukan...",
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Batal",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}