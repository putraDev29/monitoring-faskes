<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\DinkesFacilityController;
use App\Http\Controllers\ExaminationController;
use App\Http\Controllers\FacilityController;
use App\Http\Controllers\HistoryController;
use App\Http\Controllers\HospitalController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ReportController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

Route::post('/reset-password', [AuthController::class, 'resetPassword']);

Route::middleware([
    'auth:sanctum',
    'role:admin,admin_utama'
])->group(function () {

    Route::get('/dashboard', [DashboardController::class, 'dashboardAdmin']);

    Route::get('/facilities', [FacilityController::class, 'index']);
    Route::post('/facilities', [FacilityController::class, 'store']);
    Route::get('/facilities/{id}', [FacilityController::class, 'show']);
    Route::put('/facilities/{id}', [FacilityController::class, 'update']);
    Route::delete('/facilities/{id}', [FacilityController::class, 'destroy']);

    Route::get('/histories', [HistoryController::class, 'histories']);

    Route::get('/profile', [ProfileController::class, 'profileAdmin']);

    Route::get('/hospitals', [HospitalController::class, 'AdminhospitalList']);
    Route::get('/hospitals/{id}', [HospitalController::class, 'AdminhospitalDetail']);

    Route::resource('examinations', ExaminationController::class);
    Route::get('/hospitals/{hospital}/examinations', [ExaminationController::class, 'hospitalExaminations']);

    Route::get('hospitals/{hospital_id}/facilities', [FacilityController::class, 'getFacilityByHospital']);
    Route::get('hospitals/{hospital_id}/facilities/{id}', [FacilityController::class, 'detailFacility']);

    Route::get('/hospital-profile', [ProfileController::class, 'hospitalProfile']);
    Route::put('/hospital-profile', [ProfileController::class, 'updateHospital']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'readNotification']);
    Route::get('/notifications/unread/count', [NotificationController::class, 'unreadCount']);
});

Route::middleware([
    'auth:sanctum',
    'role:admin_utama'
])->group(function () {

    Route::post('/register', [AuthController::class, 'register']);

    Route::get('/users', [AuthController::class, 'listUser']);
    Route::get('/users/{id}', [AuthController::class, 'showUser']);

    Route::put('/users/{id}', [AuthController::class, 'update']);
    Route::delete('/users/{id}', [AuthController::class, 'delete']);
});

Route::prefix('dinkes')
    ->middleware([
        'auth:sanctum',
        'role:dinkes,dinkes_utama'
    ])
    ->group(function () {

        Route::get('/dashboard', [DashboardController::class, 'dashboard']);

        Route::get('/hospitals', [HospitalController::class, 'hospitals']);
        Route::get('/hospitals/{id}', [HospitalController::class, 'hospitalDetail']);

        Route::get('/hospitals/{hospital_id}/facilities', [DinkesFacilityController::class, 'facilities']);
        Route::get('/hospitals/{hospital_id}/facilities/{id}', [DinkesFacilityController::class, 'facilityDetail']);

        Route::get('/hospitals/{hospital}/examinations', [ExaminationController::class, 'dinkesExaminationsList']);
        Route::get('/hospitals/{hospital}/examinations/{examination}', [ExaminationController::class, 'dinkesExaminationsDetail']);

        Route::get('/critical-facilities', [DinkesFacilityController::class, 'criticalFacilities']);

        Route::get('/profile', [ProfileController::class, 'profileDinkes']);

        Route::get('/histories', [HistoryController::class, 'dinkesHistory']);

        Route::get('/reports', [ReportController::class, 'index']);
        Route::get('/reports/export/{format}', [ReportController::class, 'export'])
            ->where('format', 'pdf|excel|csv');

        Route::get('/notifications', [NotificationController::class, 'notifikasiDinkes']);
        Route::post('/notifications/{id}/read', [NotificationController::class, 'readNotification']);
        Route::get('/notifications/unread/count', [NotificationController::class, 'unreadCount']);
    });


Route::prefix('dinkes')
    ->middleware([
        'auth:sanctum',
        'role:dinkes_utama'
    ])
    ->group(function () {

        Route::post('/register', [AuthController::class, 'register']);

        Route::get('/users', [AuthController::class, 'listUser']);
        Route::get('/users/{id}', [AuthController::class, 'showUser']);

        Route::put('/users/{id}', [AuthController::class, 'update']);
        Route::delete('/users/{id}', [AuthController::class, 'delete']);
    });

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
