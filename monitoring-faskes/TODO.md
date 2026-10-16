# TODO - Update Facility store by hospital_id (facility type)

- [x] Perbarui `app/Http/Controllers/FacilityController.php` pada method `store()`:
  - [x] Cari `FacilityType` berdasarkan `hospital_id` admin dan `name` dari request
  - [x] Jika ada pakai `facility_type_id` yang ditemukan
  - [x] Jika tidak ada buat `FacilityType` baru dengan `hospital_id` admin
  - [x] Tetap cek duplikasi facility: jika hospital sudah punya `Facility` dengan type name yang sama, balas `message => 'Nama fasilitas sudah ada'` dan status 422
- [x] Pastikan transaksi tetap konsisten (beginTransaction/commit/rollback)
- [ ] Verifikasi logika update history & notification tetap berjalan


