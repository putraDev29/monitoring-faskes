<?php

namespace App\Http\Controllers;

use App\Models\Facility;
use App\Models\Hospital;
use Illuminate\Http\Request;

class DashboardController extends Controller
{

    public function dashboard()
    {
        $summary = Facility::selectRaw('
            COUNT(*) as total_facility,
            SUM(available_unit) as total_available,
            SUM(CASE WHEN status = "tersedia" THEN 1 ELSE 0 END) as tersedia,
            SUM(CASE WHEN status = "terbatas" THEN 1 ELSE 0 END) as terbatas,
            SUM(CASE WHEN status = "penuh" THEN 1 ELSE 0 END) as penuh,
            ROUND((SUM(available_unit) / SUM(total_unit)) * 100) as percentage
        ')->first();

        return response()->json([
            'success' => true,
            'message' => 'Dashboard dinkes berhasil dimuat',

            'data' => [

                'total_hospital' => Hospital::count(),

                'summary' => $summary,

                'critical_alerts' => Facility::with([
                    'hospital',
                    'facilityType'
                ])
                    ->where('status', 'penuh')
                    ->latest()
                    ->take(5)
                    ->get()
            ]
        ]);
    }

    public function dashboardAdmin(Request $request)
    {
        $user = $request->user();

        $hospital = Hospital::find($user->hospital_id);

        $summary = Facility::where('hospital_id', $user->hospital_id)
            ->selectRaw("
            COUNT(*) as total_facility,
            SUM(available_unit) as total_available_unit,
            SUM(status = 'tersedia') as tersedia,
            SUM(status = 'terbatas') as terbatas,
            SUM(status = 'penuh') as penuh,
            ROUND((SUM(available_unit) / SUM(total_unit)) * 100) as percentage
        ")
            ->first();

        $alerts = Facility::join(
            'facility_types',
            'facilities.facility_type_id',
            '=',
            'facility_types.id'
        )
            ->where('facilities.hospital_id', $user->hospital_id)
            ->whereIn('facilities.status', ['terbatas', 'penuh'])
            ->select(
                'facilities.id as facility_id',
                'facility_types.name as facility_name',
                'facilities.available_unit as available',
                'facilities.total_unit as total',
                'facilities.percentage',
                'facilities.status'
            )
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Dashboard berhasil dimuat',

            'data' => [

                'hospital' => [
                    'id' => $hospital->id,
                    'name' => $hospital->name,
                    'description' => $hospital->description,
                    'city' => $hospital->city,
                    'status' => $hospital->status,
                ],

                'summary' => $summary,

                'alerts' => $alerts,
            ]
        ]);
    }

}

