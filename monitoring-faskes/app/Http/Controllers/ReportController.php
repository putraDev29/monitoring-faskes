<?php

namespace App\Http\Controllers;

use App\Models\Facility;
use App\Models\FacilityType;
use App\Models\Hospital;
use App\Exports\FacilityReportExport;
use App\Services\ReportPdfService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        try {

            $filters = $this->resolveFilters($request);

            $totalHospital = Hospital::count();

            $summaryQuery = Facility::query();

            $this->applyFilters(
                $summaryQuery,
                $filters
            );

            $summary = $summaryQuery
                ->selectRaw('
                COUNT(*) as total_facility,
                COALESCE(SUM(available_unit),0) as total_available,
                COALESCE(SUM(total_unit),0) as total_unit,
                ROUND(
                    CASE
                        WHEN COALESCE(SUM(total_unit),0) > 0
                        THEN (
                            COALESCE(SUM(available_unit),0)
                            /
                            COALESCE(SUM(total_unit),0)
                        ) * 100
                        ELSE 0
                    END
                ) as percentage
            ')
                ->first();

            $graph = $this->buildGraph($filters);

            return response()->json([
                'success' => true,
                'message' => 'Laporan berhasil dimuat',

                'period' => $request->period ?? '7days',

                'filters' => $filters,

                'data' => [
                    'summary' => [
                        'total_hospital' =>
                            (int) $totalHospital,

                        'total_facility' =>
                            (int) ($summary->total_facility ?? 0),

                        'average_percentage' =>
                            (float) ($summary->percentage ?? 0),
                    ],

                    'graph' => $graph ?? [],

                    'export' => [
                        'pdf' =>
                            '/api/dinkes/reports/export/pdf',

                        'excel' =>
                            '/api/dinkes/reports/export/excel',

                        'csv' =>
                            '/api/dinkes/reports/export/csv',
                    ],
                ],
            ]);
        } catch (\Throwable $e) {

            \Log::error('REPORT ERROR', [
                'message' => $e->getMessage(),
                'line' => $e->getLine(),
                'file' => $e->getFile(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Server Error',

                'error' => $e->getMessage(),

                'line' => $e->getLine(),

                'file' => basename($e->getFile()),
            ], 500);
        }
    }

    /**
     * GET /api/dinkes/reports/export/{format}
     * format = pdf | excel | csv
     * Accepts same query params as index().
     */
    public function export(Request $request, string $format)
    {
        $request->validate([
            'period' => 'nullable|in:today,7days,30days,custom',
            'date_from' => 'nullable|date|required_if:period,custom',
            'date_to' => 'nullable|date|required_if:period,custom|after_or_equal:date_from',
            'hospital_id' => 'nullable|integer|exists:hospitals,id',
            'facility_type' => 'nullable|string',
        ]);

        $filters = $this->resolveFilters($request);
        $rows = $this->buildReportRows($filters);
        $meta = $this->buildMeta($filters);
        $filename = 'laporan-fasilitas-' . now()->format('Ymd_His');

        return match ($format) {
            'pdf' => $this->exportPdf($rows, $meta, $filename),
            'excel' => $this->exportExcel($rows, $meta, $filename . '.xlsx', 'xlsx'),
            'csv' => $this->exportExcel($rows, $meta, $filename . '.csv', 'csv'),
            default => response()->json(['success' => false, 'message' => 'Format tidak didukung'], 422),
        };
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private function resolveFilters(Request $request): array
    {
        $period = $request->period ?? '7days';

        $dateFrom = match ($period) {
            'today' => Carbon::today(),
            '30days' => Carbon::now()->subDays(29)->startOfDay(),
            'custom' => Carbon::parse($request->date_from)->startOfDay(),
            default => Carbon::now()->subDays(6)->startOfDay(), // 7days
        };

        $dateTo = $period === 'custom'
            ? Carbon::parse($request->date_to)->endOfDay()
            : Carbon::now()->endOfDay();

        return [
            'period' => $period,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'hospital_id' => $request->hospital_id,
            'facility_type' => $request->facility_type,
        ];
    }

    private function applyFilters($query, array $filters): void
    {
        if ($filters['hospital_id']) {
            $query->where('hospital_id', $filters['hospital_id']);
        }

        if ($filters['facility_type']) {
            $query->whereHas('facilityType', function ($q) use ($filters) {
                $q->where('name', $filters['facility_type']);
            });
        }
    }

    private function buildGraph(array $filters): array
    {
        // Build day-by-day series between date_from and date_to
        $graph = [];
        $cursor = $filters['date_from']->copy()->startOfDay();
        $end = $filters['date_to']->copy()->startOfDay();

        while ($cursor->lte($end)) {
            // NOTE: Facility model has no created_at date-range logic in the
            // original code either — adjust the whereDate clause to match your
            // actual schema (e.g. a facility_logs / snapshots table).
            $daily = Facility::selectRaw('
                    SUM(available_unit) as total_available,
                    SUM(total_unit) as total_unit
                ')
                ->when($filters['hospital_id'], fn($q) => $q->where('hospital_id', $filters['hospital_id']))
                ->when(
                    $filters['facility_type'],
                    fn($q) =>
                    $q->whereHas('facilityType', fn($fq) => $fq->where('name', $filters['facility_type']))
                )
                ->whereDate('updated_at', $cursor)
                ->first();

            $percentage = 0;
            if ($daily && $daily->total_unit > 0) {
                $percentage = round(($daily->total_available / $daily->total_unit) * 100);
            }

            $graph[] = [
                'date' => $cursor->format('d/m'),
                'percentage' => $percentage,
            ];

            $cursor->addDay();
        }

        return $graph;
    }

    private function buildReportRows(array $filters): \Illuminate\Support\Collection
    {
        return Facility::with(['hospital', 'facilityType'])
            ->when($filters['hospital_id'], fn($q) => $q->where('hospital_id', $filters['hospital_id']))
            ->when(
                $filters['facility_type'],
                fn($q) =>
                $q->whereHas('facilityType', fn($fq) => $fq->where('name', $filters['facility_type']))
            )
            ->get()
            ->map(fn($f) => [
                'Rumah Sakit' => $f->hospital->name ?? '-',
                'Tipe Fasilitas' => $f->facilityType->name ?? '-',
                'Total Unit' => $f->total_unit,
                'Unit Terpakai' => $f->used_unit,
                'Unit Tersedia' => $f->available_unit,
                'Persentase (%)' => $f->percentage,
                'Status' => $f->status ? 'Aktif' : 'Nonaktif',
                'Catatan' => $f->note ?? '-',
                'Diperbarui' => $f->updated_at?->format('d/m/Y H:i') ?? '-',
            ]);
    }

    private function buildMeta(array $filters): array
    {
        return [
            'Periode' => ucfirst($filters['period']),
            'Dari' => $filters['date_from']->format('d/m/Y'),
            'Sampai' => $filters['date_to']->format('d/m/Y'),
            'Filter RS' => $filters['hospital_id']
                ? (Hospital::find($filters['hospital_id'])?->name ?? $filters['hospital_id'])
                : 'Semua',
            'Tipe' => $filters['facility_type'] ?? 'Semua',
            'Dicetak' => now()->format('d/m/Y H:i'),
        ];
    }

    private function exportExcel(\Illuminate\Support\Collection $rows, array $meta, string $filename, string $format): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        $writerType = $format === 'csv' ? \Maatwebsite\Excel\Excel::CSV : \Maatwebsite\Excel\Excel::XLSX;

        return Excel::download(
            new FacilityReportExport($rows, $meta),
            $filename,
            $writerType
        );
    }

    private function exportPdf(\Illuminate\Support\Collection $rows, array $meta, string $filename): \Illuminate\Http\Response
    {
        $pdf = app(ReportPdfService::class)->generate($rows, $meta);

        return $pdf->download($filename . '.pdf');
    }
}
