<?php

namespace App\Http\Controllers;

use App\Models\Examination;
use App\Models\Hospital;
use Illuminate\Http\Request;

class ExaminationController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'examination_name' => 'required|string|max:255',
            'doctor_name' => 'required|string|max:255',
            'opening_hours' => 'required',
            'closing_hours' => 'required',
        ]);

        $examination = Examination::create([
            'hospital_id' => auth()->user()->hospital_id,
            'examination_name' => $request->examination_name,
            'doctor_name' => $request->doctor_name,
            'opening_hours' => $request->opening_hours,
            'closing_hours' => $request->closing_hours,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Examination created successfully',
            'data' => $examination
        ], 201);
    }

    public function index(Request $request)
    {
        $hospitalId = auth()->user()->hospital_id;

        $data = Examination::where('hospital_id', $hospitalId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    public function show($id)
    {
        $examination = Examination::where('hospital_id', auth()->user()->hospital_id)
            ->find($id);

        if (!$examination) {
            return response()->json([
                'success' => false,
                'message' => 'Examination not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $examination
        ]);
    }

    public function hospitalExaminations(Hospital $hospital)
    {
        $examinations = Examination::where('hospital_id', $hospital->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'hospital' => [
                'id' => $hospital->id,
                'name' => $hospital->name,
            ],
            'data' => $examinations,
        ]);
    }

    public function update(Request $request, $id)
    {
        $examination = Examination::where(
            'hospital_id',
            auth()->user()->hospital_id
        )->find($id);

        if (!$examination) {
            return response()->json([
                'success' => false,
                'message' => 'Examination not found'
            ], 404);
        }

        $request->validate([
            'examination_name' => 'required|string|max:255',
            'doctor_name' => 'required|string|max:255',
            'opening_hours' => 'sometimes',
            'closing_hours' => 'sometimes',
        ]);

        $examination->update([
            'examination_name' => $request->examination_name,
            'doctor_name' => $request->doctor_name,
            'opening_hours' => $request->opening_hours,
            'closing_hours' => $request->closing_hours,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Examination updated successfully',
            'data' => $examination
        ]);
    }

    public function destroy($id)
    {
        $examination = Examination::where(
            'hospital_id',
            auth()->user()->hospital_id
        )->find($id);

        if (!$examination) {
            return response()->json([
                'success' => false,
                'message' => 'Examination not found or access denied'
            ], 404);
        }

        $examination->delete();

        return response()->json([
            'success' => true,
            'message' => 'Examination deleted successfully'
        ]);
    }

    public function dinkesExaminationsList(Hospital $hospital)
    {
        $examinations = $hospital->examinations()
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'hospital' => [
                'id' => $hospital->id,
                'name' => $hospital->name,
            ],
            'total' => $examinations->count(),
            'data' => $examinations,
        ]);
    }

    public function dinkesExaminationsDetail(
        Hospital $hospital,
        $examinationId
    ) {
        $examination = Examination::where('hospital_id', $hospital->id)
            ->find($examinationId);

        if (!$examination) {
            return response()->json([
                'success' => false,
                'message' => 'Examination not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'hospital' => [
                'id' => $hospital->id,
                'name' => $hospital->name,
            ],
            'data' => $examination,
        ]);
    }
}
