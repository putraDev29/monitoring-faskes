<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('facilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hospital_id')
                ->nullable()
                ->constrained('hospitals')
                ->onDelete('cascade');
            $table->foreignId('facility_type_id')->constrained('facility_types')->onDelete('cascade');
            $table->integer('total_unit');
            $table->integer('used_unit');
            $table->integer('available_unit');
            $table->decimal('percentage', 5, 2);
            $table->enum('status',['tersedia', 'terbatas', 'penuh']);
            $table->text('note')->nullable();
            $table->bigInteger('updated_by')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('facilities');
    }
};
