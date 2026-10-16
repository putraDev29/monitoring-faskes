<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;

/**
 * Multi-sheet workbook:
 *   Sheet 1 – Ringkasan (meta / info filter)
 *   Sheet 2 – Data (tabel fasilitas lengkap)
 */
class FacilityReportExport implements WithMultipleSheets
{
    public function __construct(
        private Collection $rows,
        private array $meta
    ) {}

    public function sheets(): array
    {
        return [
            new FacilityReportSummarySheet($this->meta, $this->rows),
            new FacilityReportDataSheet($this->rows),
        ];
    }
}

// ---------------------------------------------------------------------------
// Sheet 1 – Ringkasan
// ---------------------------------------------------------------------------
class FacilityReportSummarySheet implements FromCollection, WithTitle, WithStyles
{
    public function __construct(
        private array $meta,
        private Collection $rows
    ) {}

    public function title(): string
    {
        return 'Ringkasan';
    }

    public function collection(): Collection
    {
        $totalUnit      = $this->rows->sum('Total Unit');
        $totalUsed      = $this->rows->sum('Unit Terpakai');
        $totalAvailable = $this->rows->sum('Unit Tersedia');
        $avgPercentage  = $this->rows->isNotEmpty()
            ? round($this->rows->avg('Persentase (%)'), 2)
            : 0;

        $data = collect([
            ['LAPORAN FASILITAS KESEHATAN', ''],
            ['', ''],
        ]);

        foreach ($this->meta as $key => $value) {
            $data->push([$key, $value]);
        }

        $data->push(['', '']);
        $data->push(['STATISTIK KESELURUHAN', '']);
        $data->push(['Total Data Fasilitas', $this->rows->count()]);
        $data->push(['Total Unit',           $totalUnit]);
        $data->push(['Total Unit Terpakai',  $totalUsed]);
        $data->push(['Total Unit Tersedia',  $totalAvailable]);
        $data->push(['Rata-rata Tersedia',   $avgPercentage . '%']);

        return $data;
    }

    public function styles(Worksheet $sheet): array
    {
        $sheet->getColumnDimension('A')->setWidth(30);
        $sheet->getColumnDimension('B')->setWidth(30);

        return [
            1 => [
                'font'      => ['bold' => true, 'size' => 14, 'color' => ['argb' => 'FFFFFFFF']],
                'fill'      => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FF1E40AF']],
                'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            ],
        ];
    }
}

// ---------------------------------------------------------------------------
// Sheet 2 – Data
// ---------------------------------------------------------------------------
class FacilityReportDataSheet implements FromCollection, WithTitle, WithHeadings, WithStyles, ShouldAutoSize
{
    public function __construct(private Collection $rows) {}

    public function title(): string
    {
        return 'Data Fasilitas';
    }

    public function collection(): Collection
    {
        return $this->rows->map(fn($row) => array_values($row));
    }

    public function headings(): array
    {
        return array_keys($this->rows->first() ?? []);
    }

    public function styles(Worksheet $sheet): array
    {
        $lastRow = $this->rows->count() + 1;

        // Header row
        $sheet->getStyle('A1:I1')->applyFromArray([
            'font' => [
                'bold'  => true,
                'color' => ['argb' => 'FFFFFFFF'],
            ],
            'fill' => [
                'fillType'   => Fill::FILL_SOLID,
                'startColor' => ['argb' => 'FF1E40AF'],
            ],
            'alignment' => [
                'horizontal' => Alignment::HORIZONTAL_CENTER,
                'vertical'   => Alignment::VERTICAL_CENTER,
            ],
        ]);

        // Zebra stripes for data rows
        for ($i = 2; $i <= $lastRow; $i++) {
            $color = ($i % 2 === 0) ? 'FFEFF6FF' : 'FFFFFFFF';
            $sheet->getStyle("A{$i}:I{$i}")->applyFromArray([
                'fill' => [
                    'fillType'   => Fill::FILL_SOLID,
                    'startColor' => ['argb' => $color],
                ],
            ]);
        }

        // All-around thin border for entire table
        if ($lastRow >= 1) {
            $sheet->getStyle("A1:I{$lastRow}")->applyFromArray([
                'borders' => [
                    'allBorders' => [
                        'borderStyle' => Border::BORDER_THIN,
                        'color'       => ['argb' => 'FFCBD5E1'],
                    ],
                ],
            ]);
        }

        // Percentage column – center align
        $sheet->getStyle("F2:F{$lastRow}")->getAlignment()
            ->setHorizontal(Alignment::HORIZONTAL_CENTER);

        // Number columns – right align
        $sheet->getStyle("C2:E{$lastRow}")->getAlignment()
            ->setHorizontal(Alignment::HORIZONTAL_RIGHT);

        return [];
    }
}
