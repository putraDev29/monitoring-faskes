<?php

namespace App\Http\Controllers;

use App\Models\Facility;
use App\Models\Hospital;
use Illuminate\Http\Request;

class HospitalController extends Controller
{
    public function AdminhospitalList(Request $request)
    {
        $search = $request->search;

        $hospitals = Hospital::query();

        if ($search) {

            $hospitals->where(
                'name',
                'like',
                "%{$search}%"
            );
        }

        $data = $hospitals
            ->withSum('facilities as total_available', 'available_unit')
            ->withSum('facilities as total_unit', 'total_unit')
            ->latest()
            ->get()
            ->map(function ($hospital) {

                $available = $hospital->total_available ?? 0;
                $total = $hospital->total_unit ?? 0;

                $percentage = 0;
                if ($total > 0) {
                    $percentage = round(
                        ($available / $total) * 100
                    );
                }

                if ($percentage <= 20) {
                    $status = 'penuh';
                } elseif ($percentage <= 50) {
                    $status = 'terbatas';
                } else {
                    $status = 'tersedia';
                }

                return [
                    'id' => $hospital->id,
                    'logo' => $hospital->logo,
                    'name' => $hospital->name,
                    'address' => $hospital->address,
                    'status' => $status,
                    'percentage' => $percentage,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Data rumah sakit berhasil dimuat',
            'total' => $data->count(),
            'data' => $data
        ]);
    }

    public function hospitals(Request $request)
    {
        $search = $request->search;

        $hospitals = Hospital::query();

        if ($search) {

            $hospitals->where(
                'name',
                'like',
                "%{$search}%"
            );
        }

        $data = $hospitals
            ->withSum('facilities as total_available', 'available_unit')
            ->withSum('facilities as total_unit', 'total_unit')
            ->latest()
            ->get()
            ->map(function ($hospital) {

                $available = $hospital->total_available ?? 0;
                $total = $hospital->total_unit ?? 0;

                $percentage = 0;
                if ($total > 0) {
                    $percentage = round(
                        ($available / $total) * 100
                    );
                }

                if ($percentage <= 20) {
                    $status = 'penuh';
                } elseif ($percentage <= 50) {
                    $status = 'terbatas';
                } else {
                    $status = 'tersedia';
                }

                return [
                    'id' => $hospital->id,
                    'logo' => $hospital->logo,
                    'name' => $hospital->name,
                    'address' => $hospital->address,
                    'status' => $status,
                    'percentage' => $percentage,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Data rumah sakit berhasil dimuat',
            'total' => $data->count(),
            'data' => $data
        ]);
    }

    public function hospitalDetail($id)
    {
        $hospital = Hospital::find($id);

        if (!$hospital) {
            return response()->json([
                'success' => false,
                'message' => 'Rumah sakit tidak ditemukan'
            ], 404);
        }

        $summary = Facility::where(
            'hospital_id',
            $id
        )
            ->selectRaw('
            COUNT(*) as total_facility,
            SUM(available_unit) as total_available,
            SUM(total_unit) as total_unit,
            ROUND((SUM(available_unit) / SUM(total_unit)) * 100) as percentage
        ')
            ->first();

        $status = 'penuh';

        if ($summary->percentage > 50) {
            $status = 'tersedia';
        } elseif ($summary->percentage > 20) {
            $status = 'terbatas';
        }

        $facilities = Facility::with('facilityType')
            ->where('hospital_id', $id)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Detail rumah sakit berhasil dimuat',

            'data' => [
                'hospital' => $hospital,
                'summary' => [
                    'total_facility' =>
                        $summary->total_facility,
                    'total_available' =>
                        $summary->total_available,
                    'total_unit' =>
                        $summary->total_unit,
                    'percentage' =>
                        $summary->percentage,
                    'status' => $status
                ],
                'facilities' => $facilities
            ]
        ]);
    }

    public function AdminhospitalDetail($id)
    {
        $hospital = Hospital::find($id);

        if (!$hospital) {
            return response()->json([
                'success' => false,
                'message' => 'Rumah sakit tidak ditemukan'
            ], 404);
        }

        $summary = Facility::where(
            'hospital_id',
            $id
        )
            ->selectRaw('
            COUNT(*) as total_facility,
            SUM(available_unit) as total_available,
            SUM(total_unit) as total_unit,
            ROUND((SUM(available_unit) / SUM(total_unit)) * 100) as percentage
        ')
            ->first();

        $status = 'penuh';

        if ($summary->percentage > 50) {
            $status = 'tersedia';
        } elseif ($summary->percentage > 20) {
            $status = 'terbatas';
        }

        $facilities = Facility::with('facilityType')
            ->where('hospital_id', $id)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Detail rumah sakit berhasil dimuat',

            'data' => [
                'hospital' => $hospital,
                'summary' => [
                    'total_facility' =>
                        $summary->total_facility,
                    'total_available' =>
                        $summary->total_available,
                    'total_unit' =>
                        $summary->total_unit,
                    'percentage' =>
                        $summary->percentage,
                    'status' => $status
                ],
                'facilities' => $facilities
            ]
        ]);
    }
}
