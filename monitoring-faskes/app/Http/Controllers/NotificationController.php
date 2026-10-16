<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Notification::where(
            'hospital_id',
            $user->hospital_id
        )->latest();

        if ($request->filter == 'read') {
            $query->where('is_read', true);
        }

        if ($request->filter == 'unread') {
            $query->where('is_read', false);
        }

        return response()->json([
            'success' => true,
            'data' => $query->get()
        ]);
    }

    public function notifikasiDinkes(Request $request)
    {

        $query = Notification::latest();

        if ($request->filter == 'read') {
            $query->where('is_read', true);
        }

        if ($request->filter == 'unread') {
            $query->where('is_read', false);
        }

        return response()->json([
            'success' => true,
            'data' => $query->get()
        ]);
    }

    public function readNotification($id)
    {
        $notification = Notification::findOrFail($id);

        $notification->update([
            'is_read' => true
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Notification dibaca'
        ]);
    }

    public function unreadCount(Request $request)
    {
        $count = Notification::where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'count' => $count
        ]);
    }
}
