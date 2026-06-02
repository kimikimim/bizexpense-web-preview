package com.example.expense_pro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

/**
 * SMS 수신 브로드캐스트 리시버
 * 카드 결제 문자를 수신하면 Flutter로 전달
 */
class SmsBroadcastReceiver : BroadcastReceiver() {

    companion object {
        const val FLUTTER_CHANNEL = "com.example.expense_pro/sms"
        const val ENGINE_ID = "expense_pro_engine"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        val fullBody = StringBuilder()
        var sender = ""

        for (msg in messages) {
            sender = msg.originatingAddress ?: ""
            fullBody.append(msg.messageBody)
        }

        val body = fullBody.toString()

        // 카드 승인 관련 키워드 필터
        val isCardSms = body.contains("승인") &&
            (body.contains("카드") || body.contains("원") || body.contains("결제"))

        if (!isCardSms) return

        // Flutter 엔진이 실행 중이면 직접 전달
        val engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (engine != null) {
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                MethodChannel(engine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL)
                    .invokeMethod("onCardSms", mapOf(
                        "sender" to sender,
                        "body" to body,
                    ))
            }
        }
    }
}
