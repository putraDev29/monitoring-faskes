<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <title>Laporan Fasilitas Kesehatan</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'DejaVu Sans', sans-serif;
            font-size: 9px;
            color: #1e293b;
            background: #fff;
        }

        /* ── Header ── */
        .page-header {
            background: #1e40af;
            color: #fff;
            padding: 14px 20px;
            border-radius: 4px;
            margin-bottom: 12px;
        }

        .page-header h1 {
            font-size: 15px;
            font-weight: 700;
            letter-spacing: .4px;
        }

        .page-header p {
            font-size: 8px;
            margin-top: 3px;
            opacity: .85;
        }

        /* ── Meta + Stats row ── */
        .info-row {
            display: table;
            width: 100%;
            margin-bottom: 12px;
            border-spacing: 8px 0;
        }

        .info-box {
            display: table-cell;
            width: 50%;
            vertical-align: top;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            padding: 8px 10px;
        }

        .info-box h3 {
            font-size: 8px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .5px;
            color: #64748b;
            margin-bottom: 5px;
            padding-bottom: 4px;
            border-bottom: 1px solid #e2e8f0;
        }

        .info-box table {
            width: 100%;
            border-collapse: collapse;
        }

        .info-box td {
            padding: 2px 0;
        }

        .info-box td:first-child {
            color: #64748b;
            width: 45%;
        }

        .info-box td:last-child {
            font-weight: 600;
        }

        /* ── Stat cards ── */
        .stat-card {
            display: inline-block;
            width: 22%;
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 4px;
            padding: 6px 8px;
            margin-right: 3%;
            vertical-align: top;
            text-align: center;
        }

        .stat-card:last-child {
            margin-right: 0;
        }

        .stat-card .val {
            font-size: 16px;
            font-weight: 700;
            color: #1e40af;
        }

        .stat-card .lbl {
            font-size: 7.5px;
            color: #475569;
            margin-top: 2px;
        }

        /* ── Table ── */
        .section-title {
            font-size: 9px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .4px;
            color: #475569;
            margin: 12px 0 5px;
        }

        table.data {
            width: 100%;
            border-collapse: collapse;
            font-size: 8px;
        }

        table.data thead tr {
            background: #1e40af;
            color: #fff;
        }

        table.data thead th {
            padding: 5px 6px;
            text-align: left;
            font-weight: 600;
            letter-spacing: .2px;
        }

        table.data tbody tr:nth-child(even) {
            background: #f1f5f9;
        }

        table.data tbody tr:hover {
            background: #dbeafe;
        }

        table.data tbody td {
            padding: 4px 6px;
            border-bottom: 1px solid #e2e8f0;
        }

        /* ── Percentage badge ── */
        .pct {
            display: inline-block;
            padding: 1px 5px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 7.5px;
        }

        .pct-high {
            background: #dcfce7;
            color: #166534;
        }

        .pct-mid {
            background: #fef9c3;
            color: #854d0e;
        }

        .pct-low {
            background: #fee2e2;
            color: #991b1b;
        }

        /* ── Footer ── */
        .page-footer {
            margin-top: 14px;
            padding-top: 6px;
            border-top: 1px solid #e2e8f0;
            font-size: 7.5px;
            color: #94a3b8;
            text-align: center;
        }
    </style>
</head>

<body>

    {{-- Header --}}
    <div class="page-header">
        <h1>Laporan Fasilitas Kesehatan</h1>
        <p>Sistem Informasi Ketersediaan Fasilitas – Dinas Kesehatan</p>
    </div>

    {{-- Meta + Stats --}}
    <div class="info-row">
        {{-- Filter info --}}
        <div class="info-box">
            <h3>Informasi Filter</h3>
            <table>
                @foreach ($meta as $key => $val)
                    <tr>
                        <td>{{ $key }}</td>
                        <td>{{ $val }}</td>
                    </tr>
                @endforeach
            </table>
        </div>

        {{-- Summary stats --}}
        <div class="info-box">
            <h3>Ringkasan Data</h3>
            <br>
            <div>
                <div class="stat-card">
                    <div class="val">{{ $stats['total_rows'] }}</div>
                    <div class="lbl">Total Fasilitas</div>
                </div>
                <div class="stat-card">
                    <div class="val">{{ $stats['total_unit'] }}</div>
                    <div class="lbl">Total Unit</div>
                </div>
                <div class="stat-card">
                    <div class="val">{{ $stats['total_available'] }}</div>
                    <div class="lbl">Tersedia</div>
                </div>
                <div class="stat-card">
                    <div class="val">{{ $stats['avg_percentage'] }}%</div>
                    <div class="lbl">Rata-rata Tersedia</div>
                </div>
            </div>
        </div>
    </div>

    {{-- Data table --}}
    <div class="section-title">Detail Data Fasilitas</div>

    <table class="data">
        <thead>
            <tr>
                <th style="width:4%">#</th>
                <th style="width:20%">Rumah Sakit</th>
                <th style="width:12%">Tipe Fasilitas</th>
                <th style="width:8%; text-align:right">Total Unit</th>
                <th style="width:8%; text-align:right">Terpakai</th>
                <th style="width:8%; text-align:right">Tersedia</th>
                <th style="width:9%; text-align:center">Persentase</th>
                <th style="width:7%; text-align:center">Status</th>
                <th>Catatan</th>
                <th style="width:11%">Diperbarui</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($rows as $i => $row)
                @php
                    $pct = (float) $row['Persentase (%)'];
                    $pctClass = $pct >= 60 ? 'pct-high' : ($pct >= 30 ? 'pct-mid' : 'pct-low');
                @endphp
                <tr>
                    <td style="text-align:center; color:#94a3b8">{{ $i + 1 }}</td>
                    <td>{{ $row['Rumah Sakit'] }}</td>
                    <td>{{ $row['Tipe Fasilitas'] }}</td>
                    <td style="text-align:right">{{ $row['Total Unit'] }}</td>
                    <td style="text-align:right">{{ $row['Unit Terpakai'] }}</td>
                    <td style="text-align:right">{{ $row['Unit Tersedia'] }}</td>
                    <td style="text-align:center">
                        <span class="pct {{ $pctClass }}">{{ $pct }}%</span>
                    </td>
                    <td style="text-align:center">
                        <span class="pct {{ $row['Status'] === 'Aktif' ? 'pct-high' : 'pct-low' }}">
                            {{ $row['Status'] }}
                        </span>
                    </td>
                    <td style="color:#475569">{{ $row['Catatan'] }}</td>
                    <td style="color:#475569">{{ $row['Diperbarui'] }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="10" style="text-align:center; padding:16px; color:#94a3b8">
                        Tidak ada data dengan filter yang dipilih.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    {{-- Footer --}}
    <div class="page-footer">
        Dicetak oleh Sistem Informasi Dinas Kesehatan &bull; {{ $meta['Dicetak'] ?? now()->format('d/m/Y H:i') }}
        &bull; Dokumen ini digenerate secara otomatis
    </div>

</body>

</html>
