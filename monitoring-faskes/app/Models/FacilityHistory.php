<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FacilityHistory extends Model
{

    protected $table = 'histories';
    protected $fillable = [
        'facility_id',
        'hospital_id',
        'user_id',
        'action',
        'before_total',
        'after_total',
        'before_used',
        'after_used',
        'before_available',
        'after_available',
        'before_status',
        'after_status',
        'description'
    ];

    public function facility()
    {
        return $this->belongsTo(Facility::class);
    }

    public function hospital()
    {
        return $this->belongsTo(Hospital::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
