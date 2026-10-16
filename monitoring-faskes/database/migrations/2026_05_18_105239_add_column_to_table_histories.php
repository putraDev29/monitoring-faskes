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
        Schema::table('histories', function (Blueprint $table) {
            $table->integer('before_total')->nullable()->after('action');
            $table->integer('after_total')->nullable()->after('before_total');
            $table->integer('before_used')->nullable()->after('after_total');
            $table->integer('after_used')->nullable()->after('before_used');
            $table->integer('before_available')->nullable()->after('after_used');
            $table->integer('after_available')->nullable()->after('before_available');
            $table->enum('before_status', ['tersedia', 'terbatas', 'penuh'])->nullable()->after('after_available');
            $table->enum('after_status', ['tersedia', 'terbatas', 'penuh'])->nullable()->after('before_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('histories', function (Blueprint $table) {
            //
        });
    }
};
