<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function sendMessage(Request $request)
    {
        $userMessage = $request->input('message', 'Hi');
        $apiKey = config('services.openai.key');

        if (!$apiKey) {
            return response()->json([
                'reply' => 'ERROR: OpenAI API key পাওয়া যায়নি।'
            ]);
        }

        // cURL দিয়ে সরাসরি OpenAI API কল
        $ch = curl_init('https://api.openai.com/v1/chat/completions');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $apiKey
        ]);

        $payload = [
            'model' => env('OPENAI_MODEL', 'gpt-4o-mini'),
            'messages' => [
                ['role' => 'system', 'content' => 'You are Maya, a helpful assistant. Reply in Bengali.'],
                ['role' => 'user', 'content' => $userMessage]
            ]
        ];

        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($curlError) {
            return response()->json([
                'reply' => 'cURL Error (Hosting Restriction): ' . $curlError
            ]);
        }

        $response = json_decode($result, true);

        if ($httpCode === 200 && isset($response['choices'][0]['message']['content'])) {
            return response()->json([
                'reply' => $response['choices'][0]['message']['content']
            ]);
        }

        return response()->json([
            'reply' => 'API Error (' . $httpCode . '): ' . ($response['error']['message'] ?? $result)
        ]);
    }
}
