<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Facility;
use App\Models\FacilityHistory;
use App\Models\FacilityType;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;

class FacilityController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Facility::with('facilityType')
            ->where('hospital_id', $user->hospital_id);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $data = $query->latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Data facility berhasil dimuat',
            'filter' => $request->status,
            'total' => $data->count(),
            'data' => $data,
        ]);
    }

    public function store(Request $request)
    {
        DB::beginTransaction();

        try {

            $user = $request->user();

            $request->validate([
                'name' => 'required|string|max:255',
                'total_unit' => 'required|integer|min:0',
                'note' => 'nullable|string',
            ]);

            // Ambil / buat facility type per hospital.
            // Gunakan (hospital_id, name) karena facility_types.name UNIQUE global bisa membuat error.
            $facilityType = FacilityType::firstOrCreate(
                [
                    'hospital_id' => $user->hospital_id,
                    'name' => $request->name,
                ],
                [
                    'icon' => null,
                    'color' => null,
                    'description' => null,
                ]
            );

            // Cek duplikasi facility di hospital yang sama untuk type yang sama.
            $existingFacility = Facility::where('hospital_id', $user->hospital_id)
                ->whereHas('facilityType', function ($q) use ($facilityType) {
                    $q->where('hospital_id', $facilityType->hospital_id)
                        ->where('name', $facilityType->name);
                })
                ->first();

            if ($existingFacility) {
                DB::rollBack();

                return response()->json([
                    'success' => false,
                    'message' => 'Nama fasilitas sudah ada'
                ], 422);
            }


            $available = $request->total_unit;

            $percentage = $request->total_unit > 0
                ? ($available / $request->total_unit) * 100
                : 0;

            if ($percentage <= 20) {
                $status = 'penuh';
            } elseif ($percentage <= 50) {
                $status = 'terbatas';
            } else {
                $status = 'tersedia';
            }

            $facility = Facility::create([
                'hospital_id' => $user->hospital_id,
                'facility_type_id' => $facilityType->id,
                'total_unit' => $request->total_unit,
                'used_unit' => 0,
                'available_unit' => $available,
                'percentage' => round($percentage, 2),
                'status' => $status,
                'note' => $request->note,
                'updated_by' => $user->id,
            ]);

            $facility->load('facilityType');

            FacilityHistory::create([
                'facility_id' => $facility->id,
                'hospital_id' => $user->hospital_id,
                'user_id' => $user->id,
                'action' => 'create',
                'before_total' => 0,
                'after_total' => $facility->total_unit,
                'before_used' => 0,
                'after_used' => 0,
                'before_available' => 0,
                'after_available' => $facility->available_unit,
                'before_status' => null,
                'after_status' => $facility->status,
                'description' =>
                    'Ditambahkan: Total Unit 0 → ' .
                    $facility->total_unit .
                    ', Terpakai 0 → 0' .
                    ', Tersedia 0 → ' .
                    $facility->available_unit,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Facility berhasil ditambahkan',
                'data' => $facility
            ], 201);

        } catch (\Throwable $e) {

            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show(Request $request, $id)
    {
        $user = $request->user();

        $facility = Facility::with('facilityType')
            ->where('hospital_id', $user->hospital_id)
            ->where('id', $id)
            ->first();

        if (!$facility) {
            return response()->json([
                'success' => false,
                'message' => 'Facility tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $facility
        ]);
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();

        DB::beginTransaction();

        try {
            $facility = Facility::where('hospital_id', $user->hospital_id)
                ->find($id);

            if (!$facility) {
                return response()->json([
                    'success' => false,
                    'message' => 'Facility tidak ditemukan'
                ], 404);
            }

            $request->validate([
                'facility_type_id' => 'sometimes|exists:facility_types,id',
                'total_unit' => 'sometimes|integer',
                'used_unit' => 'sometimes|integer',
                'note' => 'nullable|string'
            ]);

            $total = $request->total_unit ?? $facility->total_unit;
            $used = $request->used_unit ?? $facility->used_unit;

            $available = $total - $used;

            $percentage = $total > 0
                ? ($available / $total) * 100
                : 0;

            $status = 'tersedia';

            if ($percentage <= 20) {
                $status = 'penuh';
            } elseif ($percentage <= 50) {
                $status = 'terbatas';
            }

            $before = [
                'total' => $facility->total_unit,
                'used' => $facility->used_unit,
                'available' => $facility->available_unit,
                'status' => $facility->status,
            ];

            $facility->update([
                'facility_type_id' => $request->facility_type_id ?? $facility->facility_type_id,
                'total_unit' => $total,
                'used_unit' => $used,
                'available_unit' => $available,
                'percentage' => round($percentage, 2),
                'status' => $status,
                'note' => $request->note ?? $facility->note,
                'updated_by' => $user->id,
            ]);

            $changes = [];

            if ($request->has('total_unit')) {
                $changes[] = "Total Unit {$before['total']} → {$facility->total_unit}";
            }

            if ($request->has('used_unit')) {
                $changes[] = "Terpakai {$before['used']} → {$facility->used_unit}";
            }

            if ($before['status'] !== $facility->status) {
                $changes[] = "Status {$before['status']} → {$facility->status}";
            }

            FacilityHistory::create([
                'facility_id' => $facility->id,
                'hospital_id' => $user->hospital_id,
                'user_id' => $user->id,
                'action' => 'update',

                'before_total' => $before['total'],
                'after_total' => $facility->total_unit,

                'before_used' => $before['used'],
                'after_used' => $facility->used_unit,

                'before_available' => $before['available'],
                'after_available' => $facility->available_unit,

                'before_status' => $before['status'],
                'after_status' => $facility->status,

                'description' => count($changes)
                    ? 'Diupdate: ' . implode(', ', $changes)
                    : 'Tidak ada perubahan',
            ]);

            if (in_array($status, ['terbatas', 'penuh'])) {

                Notification::create([
                    'hospital_id' => $user->hospital_id,
                    'facility_id' => $facility->id,

                    'title' => match ($status) {
                        'penuh' => 'Peringatan penuh',
                        'terbatas' => 'Kondisi Terbatas',
                    },

                    'message' =>
                        $facility->facilityType->name .
                        ' tersedia ' .
                        $facility->available_unit .
                        ' dari ' .
                        $facility->total_unit .
                        ' unit (' .
                        round($percentage) .
                        '%)',

                    'type' => $status,

                    'is_read' => false,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Facility berhasil diupdate',
                'data' => $facility
            ]);
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat update facility',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        $facility = Facility::where(
            'hospital_id',
            $user->hospital_id
        )->find($id);

        if (!$facility) {
            return response()->json([
                'success' => false,
                'message' => 'Facility tidak ditemukan'
            ], 404);
        }

        FacilityHistory::create([
            'facility_id' => $facility->id,
            'hospital_id' => $user->hospital_id,
            'user_id' => $user->id,

            'action' => 'delete',

            'before_total' => $facility->total_unit,
            'after_total' => 0,

            'before_used' => $facility->used_unit,
            'after_used' => 0,

            'before_available' => $facility->available_unit,
            'after_available' => 0,

            'before_status' => $facility->status,
            'after_status' => null,

            'description' =>
                'Dihapus: Total Unit ' .
                $facility->total_unit .
                ' → 0, Terpakai ' .
                $facility->used_unit .
                ' → 0, Tersedia ' .
                $facility->available_unit .
                ' → 0',
        ]);

        $facility->delete();

        $facility->delete();

        return response()->json([
            'success' => true,
            'message' => 'Facility berhasil dihapus'
        ]);
    }

    public function getFacilityByHospital(Request $request, $hospital_id)
    {
        $status = $request->status;

        $facilities = Facility::with('facilityType')
            ->where('hospital_id', $hospital_id);

        if (!empty($status)) {
            $facilities->where('status', $status);
        }

        $data = $facilities->get();

        return response()->json([
            'success' => true,
            'message' => 'Data facility berhasil dimuat',
            'filter' => $status,
            'total' => $data->count(),
            'data' => $data
        ]);
    }

    public function detailFacility(Request $request, $id)
    {
        $facility = Facility::with('facilityType')
            ->where('id', $id)
            ->first();

        if (!$facility) {
            return response()->json([
                'success' => false,
                'message' => 'Facility tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $facility
        ]);
    }
}
