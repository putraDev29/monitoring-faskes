<?php

namespace App\Http\Controllers;

use App\Models\Facility;
use App\Models\FacilityHistory;
use App\Models\Hospital;
use Illuminate\Http\Request;

class DinkesFacilityController extends Controller
{
    public function facilities(Request $request, $hospital_id)
    {
        $status = $request->status;

        $hospital = Hospital::find($hospital_id);

        if (!$hospital) {
            return response()->json([
                'success' => false,
                'message' => 'Rumah sakit tidak ditemukan'
            ], 404);
        }

        $facilities = Facility::with([
            'facilityType',
            'hospital'
        ])
            ->where('hospital_id', $hospital_id);

        if ($status) {

            $facilities->where('status', $status);
        }

        $data = $facilities
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data fasilitas berhasil dimuat',

            'hospital' => [
                'id' => $hospital->id,
                'name' => $hospital->name,
                'city' => $hospital->city,
                'status' => $hospital->status,
            ],

            'filter' => $status,
            'total' => $data->count(),

            'data' => $data
        ]);
    }
    public function facilityDetail($hospital_id, $id)
    {
        $hospital = Hospital::find($hospital_id);

        if (!$hospital) {
            return response()->json([
                'success' => false,
                'message' => 'Rumah sakit tidak ditemukan'
            ], 404);
        }

        $facility = Facility::with([
            'hospital',
            'facilityType',
            'updater'
        ])
            ->where('hospital_id', $hospital_id)
            ->find($id);

        if (!$facility) {
            return response()->json([
                'success' => false,
                'message' => 'Facility tidak ditemukan'
            ], 404);
        }

        $histories = FacilityHistory::with('user')
            ->where('facility_id', $facility->id)
            ->latest()
            ->take(7)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Detail facility berhasil dimuat',

            'data' => [

                'hospital' => [
                    'id' => $hospital->id,
                    'name' => $hospital->name,
                    'city' => $hospital->city,
                    'status' => $hospital->status,
                ],

                'facility' => [
                    'id' => $facility->id,

                    'facility_type' => [
                        'id' => $facility->facilityType->id,
                        'name' => $facility->facilityType->name,
                        'icon' => $facility->facilityType->icon,
                        'color' => $facility->facilityType->color,
                        'description' => $facility->facilityType->description,
                    ],

                    'total_unit' => $facility->total_unit,
                    'used_unit' => $facility->used_unit,
                    'available_unit' => $facility->available_unit,
                    'percentage' => $facility->percentage,
                    'status' => $facility->status,
                    'note' => $facility->note,

                    'updated_by' => [
                        'id' => $facility->updater->id,
                        'name' => $facility->updater->name,
                    ],

                    'updated_at' => $facility->updated_at,
                ],

                'histories' => $histories
            ]
        ]);
    }

    public function criticalFacilities(Request $request)
    {
        $status = $request->status ?? 'penuh';

        $data = Facility::with([
            'hospital',
            'facilityType'
        ])
            ->where('status', $status)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Facility kritis berhasil dimuat',
            'data' => $data
        ]);
    }
}
