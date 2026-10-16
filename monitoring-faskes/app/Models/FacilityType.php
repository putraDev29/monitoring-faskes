<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FacilityType extends Model
{

    protected $table = 'facility_types';
    protected $fillable = [
        'hospital_id',
        'name',
        'icon',
        'color',
        'description'
    ];

    public function facilities()
    {
        return $this->hasMany(Facility::class);
    }
}
