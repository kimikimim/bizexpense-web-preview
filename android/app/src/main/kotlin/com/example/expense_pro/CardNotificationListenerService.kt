package com.example.expense_pro

import android.content.Context
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 카드사 앱 푸시 알림을 수신하여 Flutter로 전달하는 서비스
 * 설정 → 알림 → 알림 접근에서 사용자가 허용해야 동작
 */
class CardNotificationListenerService : NotificationListenerService() {

    companion object {
        private const val FLUTTER_CHANNEL = "com.example.expense_pro/notification_data"

        // 한국 주요 카드사 앱 패키지명
        private val CARD_APP_PACKAGES = setOf(
            "kr.co.samsungcard.mpocket",          // 삼성카드
            "com.kbcard.crd.appcard",              // KB국민카드 (KB Pay)
            "com.shinhan.smartcaremgr",            // 신한카드 (SOL Pay)
            "com.hyundaicard.hcapp",               // 현대카드
            "com.lottecard.appcard",               // 롯데카드
            "com.wooricard.wcard",                 // 우리카드
            "com.hanacard.app",                    // 하나카드
            "nh.smart.banking",                    // NH농협카드
            "com.bccard.bcpay",                    // BC카드
            "com.citibank.card.kr",                // 씨티카드
            // 간편결제 앱도 포함
            "com.kakao.talk",                      // 카카오페이 (카카오톡 내)
            "com.nhn.android.search",              // 네이버페이
            "viva.republica.toss",                 // 토스
        )

        // 알림 접근 권한 확인
        fun isEnabled(context: Context): Boolean {
            val packageName = context.packageName
            val flat = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            ) ?: return false
            return flat.contains(packageName)
        }

        // Flutter MethodChannel 으로 데이터 전달 (앱이 켜져 있을 때만)
        private var flutterEngine: FlutterEngine? = null

        fun setFlutterEngine(engine: FlutterEngine?) {
            flutterEngine = engine
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName ?: return

        // 카드사 앱 알림만 처리
        if (!CARD_APP_PACKAGES.contains(packageName)) return

        val notification = sbn.notification ?: return
        val extras = notification.extras ?: return

        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""

        val content = if (bigText.isNotEmpty()) bigText else text

        // 승인/결제 키워드 포함 시에만 처리
        val combined = "$title $content"
        if (!combined.contains("승인") && !combined.contains("결제")) return

        // Flutter로 전달 (앱이 foreground일 때)
        flutterEngine?.let { engine ->
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                MethodChannel(engine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL)
                    .invokeMethod("onCardNotification", mapOf(
                        "title" to title,
                        "body" to content,
                        "package" to packageName,
                    ))
            }
        }
    }
}
