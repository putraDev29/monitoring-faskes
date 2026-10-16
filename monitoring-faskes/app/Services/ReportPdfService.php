<?php

namespace App\Services;

use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Collection;

class ReportPdfService
{
    public function generate(Collection $rows, array $meta): \Barryvdh\DomPDF\PDF
    {
        $totalUnit      = $rows->sum('Total Unit');
        $totalUsed      = $rows->sum('Unit Terpakai');
        $totalAvailable = $rows->sum('Unit Tersedia');
        $avgPercentage  = $rows->isNotEmpty()
            ? round($rows->avg('Persentase (%)'), 2)
            : 0;

        $stats = [
            'total_rows'      => $rows->count(),
            'total_unit'      => $totalUnit,
            'total_used'      => $totalUsed,
            'total_available' => $totalAvailable,
            'avg_percentage'  => $avgPercentage,
        ];

        return Pdf::loadView('reports.report_pdf', [
            'rows'  => $rows,
            'meta'  => $meta,
            'stats' => $stats,
        ])
        ->setPaper('a4', 'landscape')
        ->setOption('defaultFont', 'sans-serif')
        ->setOption('dpi', 150);
    }
}
