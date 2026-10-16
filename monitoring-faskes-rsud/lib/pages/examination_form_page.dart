// pages/examination_form_page.dart

import 'package:flutter/material.dart';
import '../models/examination_model.dart';
import '../services/api_service.dart';

class ExaminationFormPage extends StatefulWidget {
  final Examination? existing;

  const ExaminationFormPage({super.key, this.existing});

  @override
  State<ExaminationFormPage> createState() => _ExaminationFormPageState();
}

class _ExaminationFormPageState extends State<ExaminationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _examinationNameCtrl;
  late final TextEditingController _doctorNameCtrl;
  late final TextEditingController _openingHoursCtrl;
  late final TextEditingController _closingHoursCtrl;

  bool _isLoading = false;
  bool get _isEdit => widget.existing != null;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _examinationNameCtrl = TextEditingController(
      text: e?.examinationName ?? '',
    );
    _doctorNameCtrl = TextEditingController(text: e?.doctorName ?? '');
    _openingHoursCtrl = TextEditingController(text: e?.openingHours ?? '');
    _closingHoursCtrl = TextEditingController(text: e?.closingHours ?? '');
  }

  @override
  void dispose() {
    _examinationNameCtrl.dispose();
    _doctorNameCtrl.dispose();
    _openingHoursCtrl.dispose();
    _closingHoursCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay initial = TimeOfDay.now();
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      final parts = text.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hh:$mm';
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final openingHours = _openingHoursCtrl.text.trim().isNotEmpty
          ? _openingHoursCtrl.text.trim()
          : widget.existing?.openingHours ?? '';
      final closingHours = _closingHoursCtrl.text.trim().isNotEmpty
          ? _closingHoursCtrl.text.trim()
          : widget.existing?.closingHours ?? '';

      if (_isEdit) {
        await ApiService.updateExamination(
          id: widget.existing!.id,
          examinationName: _examinationNameCtrl.text.trim(),
          doctorName: _doctorNameCtrl.text.trim(),
          openingHours: openingHours,
          closingHours: closingHours,
        );
      } else {
        await ApiService.createExamination(
          examinationName: _examinationNameCtrl.text.trim(),
          doctorName: _doctorNameCtrl.text.trim(),
          openingHours: openingHours,
          closingHours: closingHours,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Pemeriksaan' : 'Tambah Pemeriksaan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      // FIX: bungkus dengan SizedBox.expand agar Container mengisi penuh layar
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0D47A1).withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF0D47A1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEdit
                                    ? 'Edit data pemeriksaan'
                                    : 'Tambah pemeriksaan baru',
                                style: const TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Isi seluruh kolom di bawah ini dengan benar',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Section: Informasi Pemeriksaan ─────────────────────────
                  _sectionLabel('Informasi Pemeriksaan'),
                  const SizedBox(height: 12),

                  _buildField(
                    controller: _examinationNameCtrl,
                    label: 'Nama Pemeriksaan',
                    hint: 'Contoh: Poli Umum, Radiologi...',
                    icon: Icons.medical_services_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),

                  const SizedBox(height: 14),

                  _buildField(
                    controller: _doctorNameCtrl,
                    label: 'Nama Dokter',
                    hint: 'Contoh: dr. Budi Santoso, Sp.PD',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),

                  const SizedBox(height: 24),

                  // ── Section: Jam Operasional ───────────────────────────────
                  _sectionLabel('Jam Operasional'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          controller: _openingHoursCtrl,
                          label: 'Jam Buka',
                          hint: '08:00',
                          isRequired: !_isEdit,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeField(
                          controller: _closingHoursCtrl,
                          label: 'Jam Tutup',
                          hint: '16:00',
                          isRequired: !_isEdit,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Submit Button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isEdit ? Icons.save_outlined : Icons.add,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEdit
                                      ? 'Simpan Perubahan'
                                      : 'Tambah Pemeriksaan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // ── Cancel Button ──────────────────────────────────────────
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0D47A1),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickTime(controller),
          validator: (v) {
            if (!isRequired) return null;
            if (v == null || v.trim().isEmpty) return 'Wajib diisi';
            final parts = v.split(':');
            if (parts.length != 2) return 'Format HH:mm';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(
              Icons.schedule,
              color: Color(0xFF0D47A1),
              size: 20,
            ),
            suffixIcon: Icon(
              Icons.expand_more,
              color: Colors.grey.shade400,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0D47A1),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}