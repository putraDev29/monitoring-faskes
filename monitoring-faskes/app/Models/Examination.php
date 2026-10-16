<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Examination extends Model
{
    protected $fillable = [
        'hospital_id',
        'examination_name',
        'doctor_name',
        'opening_hours',
        'closing_hours',
    ];

    public function hospital()
    {
        return $this->belongsTo(Hospital::class);
    }
}
