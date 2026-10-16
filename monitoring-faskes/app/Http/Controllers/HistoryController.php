<?php

namespace App\Http\Controllers;

use App\Models\FacilityHistory;
use Carbon\Carbon;
use Illuminate\Http\Request;

class HistoryController extends Controller
{
    public function histories(Request $request)
    {
        $user = $request->user();

        $filter = $request->filter;

        $histories = FacilityHistory::with([
            'facility.facilityType',
            'user'
        ])
            ->where('hospital_id', $user->hospital_id);

        if ($filter == 'today') {

            $histories->whereDate(
                'created_at',
                Carbon::today()
            );
        } elseif ($filter == '7days') {

            $histories->where(
                'created_at',
                '>=',
                Carbon::now()->subDays(7)
            );
        } elseif ($filter == '30days') {

            $histories->where(
                'created_at',
                '>=',
                Carbon::now()->subDays(30)
            );
        }

        $histories = $histories
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'History berhasil dimuat',
            'filter' => $filter,
            'data' => $histories
        ]);
    }
    public function dinkesHistory(Request $request)
    {
       
        $search = $request->search;

        $facility = $request->facility;

        $filter = $request->filter;

        $histories = FacilityHistory::with([
                'facility.facilityType',
                'facility.hospital',
                'user'
            ]);

        if ($search) {

            $histories->where(function ($query) use ($search) {

                $query->where(
                    'description',
                    'like',
                    "%{$search}%"
                )

                ->orWhereHas(
                    'facility.hospital',
                    function ($q) use ($search) {

                        $q->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );
                    }
                )

                ->orWhereHas(
                    'facility.facilityType',
                    function ($q) use ($search) {

                        $q->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );
                    }
                );
            });
        }

        if ($facility && $facility != 'all') {

            $histories->whereHas(
                'facility.facilityType',
                function ($query) use ($facility) {

                    $query->where(
                        'name',
                        $facility
                    );
                }
            );
        }

        if ($filter == 'today') {

            $histories->whereDate(
                'created_at',
                Carbon::today()
            );
        }

        elseif ($filter == '7days') {

            $histories->where(
                'created_at',
                '>=',
                Carbon::now()->subDays(7)
            );
        }

        elseif ($filter == '30days') {

            $histories->where(
                'created_at',
                '>=',
                Carbon::now()->subDays(30)
            );
        }

        $data = $histories
            ->latest()
            ->get()
            ->map(function ($history) {

                return [

                    'id' => $history->id,

                    'hospital_name' =>
                        $history->facility?->hospital?->name
                        ?? '-',

                    'facility_name' =>
                        $history->facility?->facilityType?->name
                        ?? '-',

                    'action' =>
                        $history->action,

                    'description' =>
                        $history->description,

                    'status' =>
                        $history->after_status
                        ?? 'deleted',

                    'created_at' =>
                        $history->created_at,

                    'updated_by' =>
                        $history->user?->name
                        ?? '-',
                ];
            });

        return response()->json([

            'success' => true,

            'message' => 'Riwayat berhasil dimuat',

            'filter' => [

                'search' => $search,

                'facility' => $facility,

                'date' => $filter,
            ],

            'total' => $data->count(),

            'data' => $data
        ]);
    }

}
