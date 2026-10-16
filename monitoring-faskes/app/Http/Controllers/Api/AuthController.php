<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $authUser = auth()->user();

        // Hanya admin_utama dan dinkes_utama yang boleh membuat akun
        if (!in_array($authUser->role, ['admin_utama', 'dinkes_utama'])) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak memiliki akses untuk membuat akun.'
            ], 403);
        }

        $request->validate([
            'role' => 'required|in:admin,dinkes',
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone_number' => 'required|string|max:20',
            'address' => 'required|string',
            'password' => 'required|min:6|confirmed',
        ]);

        if ($authUser->role === 'admin_utama') {

            if ($request->role === 'dinkes') {
                return response()->json([
                    'success' => false,
                    'message' => 'Admin Utama tidak dapat membuat akun Dinkes.'
                ], 403);
            }

            if ($request->role !== 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Admin Utama hanya dapat membuat akun Admin.'
                ], 403);
            }
        }

        if ($authUser->role === 'dinkes_utama') {

            if ($request->role === 'admin') {
                return response()->json([
                    'success' => false,
                    'message' => 'Dinkes Utama tidak dapat membuat akun Admin.'
                ], 403);
            }

            if ($request->role !== 'dinkes') {
                return response()->json([
                    'success' => false,
                    'message' => 'Dinkes Utama hanya dapat membuat akun Dinkes.'
                ], 403);
            }
        }

        // Admin mengikuti hospital admin_utama
        $hospitalId = null;

        if ($request->role === 'admin') {
            $hospitalId = $authUser->hospital_id;
        }

        $user = User::create([
            'hospital_id' => $hospitalId,
            'name' => $request->name,
            'email' => $request->email,
            'phone_number' => $request->phone_number,
            'address' => $request->address,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dibuat.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'hospital_id' => $user->hospital_id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone_number' => $user->phone_number,
                    'address' => $user->address,
                    'role' => $user->role,
                ]
            ]
        ], 201);
    }

    public function listUser()
    {
        $authUser = auth()->user();

        if ($authUser->role === 'admin_utama') {

            $users = User::with('hospital:id,name')
                ->where('hospital_id', $authUser->hospital_id)
                ->where('role', 'admin')
                ->latest()
                ->get();

        } elseif ($authUser->role === 'dinkes_utama') {

            $users = User::with('hospital:id,name')
                ->where('role', 'dinkes')
                ->latest()
                ->get();

        } else {

            return response()->json([
                'success' => false,
                'message' => 'Tidak memiliki akses'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data user berhasil diambil',
            'data' => $users
        ]);
    }

    public function showUser($id)
    {
        $authUser = auth()->user();

        $user = User::with('hospital:id,name')->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if ($authUser->role === 'admin_utama') {

            if (
                $user->role !== 'admin' ||
                $user->hospital_id !== $authUser->hospital_id
            ) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } elseif ($authUser->role === 'dinkes_utama') {

            if ($user->role !== 'dinkes') {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } else {

            return response()->json([
                'success' => false,
                'message' => 'Tidak memiliki akses'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail user berhasil diambil',
            'data' => $user
        ]);
    }

    public function update(Request $request, $id)
    {
        $authUser = auth()->user();

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if ($authUser->role === 'admin_utama') {

            if (
                $user->role !== 'admin' ||
                $user->hospital_id !== $authUser->hospital_id
            ) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } elseif ($authUser->role === 'dinkes_utama') {

            if ($user->role !== 'dinkes') {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } else {

            return response()->json([
                'success' => false,
                'message' => 'Tidak memiliki akses'
            ], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'phone_number' => 'sometimes|string|max:20',
            'address' => 'sometimes|string|max:255',
            'password' => 'nullable|min:6|confirmed',
        ]);

        $data = $request->only([
            'name',
            'email',
            'phone_number',
            'address'
        ]);

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'User berhasil diupdate',
            'data' => $user
        ]);
    }

    public function delete($id)
    {
        $authUser = auth()->user();

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        if ($authUser->role === 'admin_utama') {

            if (
                $user->role !== 'admin' ||
                $user->hospital_id !== $authUser->hospital_id
            ) {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } elseif ($authUser->role === 'dinkes_utama') {

            if ($user->role !== 'dinkes') {
                return response()->json([
                    'success' => false,
                    'message' => 'Tidak memiliki akses'
                ], 403);
            }

        } else {

            return response()->json([
                'success' => false,
                'message' => 'Tidak memiliki akses'
            ], 403);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dihapus'
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {

            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        $user = User::with('hospital')->find(Auth::id());

        $token = $user->createToken('flutter-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'hospital_id' => $user->hospital_id,
                    'hospital_name' => $user->hospital?->name,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ]
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6|confirmed',
        ]);

        $user = User::where(
            'email',
            $request->email
        )->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        $user->update([
            'password' => Hash::make(
                $request->password
            )
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ]);
    }
}
