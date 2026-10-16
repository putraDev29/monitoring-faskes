<?php

namespace App\Http\Controllers;

use App\Models\Hospital;
use App\Models\User;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function profileAdmin(Request $request)
    {
        $auth = $request->user();

        $user = User::with('hospital')
            ->where('id', $auth->id)
            ->where('hospital_id', $auth->hospital_id)
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Profile tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile berhasil dimuat',

            'data' => [

                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone_number' => $user->phone_number,
                    'address' => $user->address,
                    'role' => $user->role,
                ],

                'hospital' => [
                    'id' => $user->hospital->id,
                    'name' => $user->hospital->name,
                    'description' => $user->hospital->description,
                    'city' => $user->hospital->city,
                    'address' => $user->hospital->address,
                    'phone' => $user->hospital->phone,
                    'logo' => $user->hospital->logo,
                    'status' => $user->hospital->status,
                ]
            ]
        ]);
    }

     public function profileDinkes(Request $request)
    {
        $user = User::find(
            $request->user()->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Profile berhasil dimuat',

            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'phone_number' => $user->phone_number,
                'address' => $user->address,
            ]
        ]);
    }
    public function hospitalProfile(Request $request)
    {
        $user = $request->user();

        $hospital = Hospital::where(
            'id',
            $user->hospital_id
        )
            ->first();

        if (!$hospital) {
            return response()->json([
                'success' => false,
                'message' => 'Rumah sakit tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profil rumah sakit berhasil dimuat',

            'data' => [
                'id' => $hospital->id,
                'name' => $hospital->name,
                'description' => $hospital->description,
                'city' => $hospital->city,
                'address' => $hospital->address,
                'phone' => $hospital->phone,
                'logo' => $hospital->logo,
                'status' => $hospital->status,
                'created_at' => $hospital->created_at,
                'updated_at' => $hospital->updated_at,
            ]
        ]);
    }

    public function updateHospital(Request $request)
    {
        $user = $request->user();

        $hospital = Hospital::find($user->hospital_id);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'city' => 'sometimes|string|max:100',
            'address' => 'nullable|string',
            'phone' => 'nullable|string|max:20',
            'logo' => 'nullable|string',
            'status' => 'sometimes|in:online,offline',
        ]);

        $hospital->update([
            'name' => $request->name ?? $hospital->name,
            'description' =>
                $request->description ?? $hospital->description,
            'city' => $request->city ?? $hospital->city,
            'address' => $request->address ?? $hospital->address,
            'phone' => $request->phone ?? $hospital->phone,
            'logo' => $request->logo ?? $hospital->logo,
            'status' => $request->status ?? $hospital->status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data rumah sakit berhasil diupdate',
            'data' => $hospital
        ]);
    }


}
