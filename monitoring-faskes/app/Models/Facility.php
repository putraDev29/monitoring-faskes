<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Notification;

class Facility extends Model
{
    protected $fillable = [
        'hospital_id',
        'facility_type_id',
        'total_unit',
        'used_unit',
        'available_unit',
        'percentage',
        'status',
        'note',
        'updated_by'
    ];

    public function hospital()
    {
        return $this->belongsTo(Hospital::class);
    }

    public function facilityType()
    {
        return $this->belongsTo(FacilityType::class);
    }

    public function updater()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function histories()
    {
        return $this->hasMany(FacilityHistory::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }
}
