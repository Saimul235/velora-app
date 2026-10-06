<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    protected $table = 'messages';

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'message',
        'image',
        'is_read',
    ];

    protected $casts = [
        'is_read' => 'boolean',
    ];
}