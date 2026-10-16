// pages/examinations_page.dart

import 'package:flutter/material.dart';
import 'package:monitoring_faskes_rsud/pages/examination_form_page.dart';
import 'package:monitoring_faskes_rsud/widgets/reusable_bottom_nav.dart';

import '../models/examination_model.dart';
import '../services/api_service.dart';

class ExaminationsPage extends StatefulWidget {
  const ExaminationsPage({super.key});

  @override
  State<ExaminationsPage> createState() => _ExaminationsPageState();
}

class _ExaminationsPageState extends State<ExaminationsPage> {
  List<Examination> examinations = [];
  List<Examination> filteredExaminations = [];

  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getExaminations();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> getExaminations() async {
    try {
      final result = await ApiService.getExaminations();
      setState(() {
        examinations = result;
        filteredExaminations = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint(e.toString());
    }
  }

  void applySearch() {
    List<Examination> result = examinations;

    if (searchQuery.isNotEmpty) {
      result = result.where((item) {
        return item.examinationName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            item.doctorName.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() => filteredExaminations = result);
  }

  // ── Navigasi ke Form ───────────────────────────────────────────────────────

  Future<void> _navigateToForm({Examination? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ExaminationFormPage(existing: existing),
      ),
    );

    // Refresh list jika form berhasil disimpan
    if (result == true) {
      setState(() => isLoading = true);
      await getExaminations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existing == null
                  ? "Pemeriksaan berhasil ditambahkan"
                  : "Pemeriksaan berhasil diperbarui",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(Examination item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Hapus Pemeriksaan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Yakin ingin menghapus "${item.examinationName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteExamination(item.id);
        await getExaminations();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Pemeriksaan berhasil dihapus"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: $e"),
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
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),

      bottomNavigationBar: const ReusableBottomNav(selected: 3),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Daftar Pemeriksaan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _navigateToForm(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Scaffold(
              // ← bungkus dengan Scaffold putih sementara loading
              backgroundColor: Color(0xFFF5F7FB),
              body: Center(child: CircularProgressIndicator()),
            )
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              // ── PERUBAHAN 3: padding top 16 di Column dipindah ke sini ──
              // agar lengkungan tidak terpotong oleh padding lama
              child: Column(
                children: [
                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        applySearch();
                      },
                      decoration: InputDecoration(
                        hintText: "Cari pemeriksaan atau dokter...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // COUNT BADGE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${filteredExaminations.length} pemeriksaan",
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LIST
                  Expanded(
                    child: filteredExaminations.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredExaminations.length,
                            itemBuilder: (context, index) =>
                                _buildCard(filteredExaminations[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────

  Widget _buildCard(Examination item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.08),
        onTap: () => _navigateToForm(existing: item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF0D47A1),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.examinationName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.doctorName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${item.openingHours} – ${item.closingHours}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ACTIONS
              Column(
                children: [
                  // Edit
                  GestureDetector(
                    onTap: () => _navigateToForm(existing: item),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Delete
                  GestureDetector(
                    onTap: () => _confirmDelete(item),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 17,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 4),

              // ARROW
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? "Belum ada data pemeriksaan"
                : "Tidak ditemukan hasil untuk\n\"$searchQuery\"",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Tambah Pemeriksaan"),
            ),
          ],
        ],
      ),
    );
  }
}
