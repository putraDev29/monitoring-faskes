<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Notification;

class Hospital extends Model
{

    protected $fillable = [
        'name',
        'logo',
        'description',
        'city',
        'address',
        'phone',
        'email',
        'updated_by'
    ];
    public function users()
    {
        return $this->hasMany(User::class);
    }
    public function facilities()
    {
        return $this->hasMany(Facility::class);
    }
    public function histories()
    {
        return $this->hasMany(FacilityHistory::class);
    }
    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function examinations()
    {
        return $this->hasMany(Examination::class);
    }
}
