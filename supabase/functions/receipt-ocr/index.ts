// supabase/functions/receipt-ocr/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request): Promise<Response> => {
  // 1) CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // 2) 허용 메서드 체크
  if (req.method !== "POST") {
    return new Response("Method not allowed", {
      status: 405,
      headers: corsHeaders,
    });
  }

  try {
    // 3) body 파싱
    const body = await req.json().catch(() => null);
    if (!body || typeof body !== "object") {
      return new Response("Invalid JSON body", {
        status: 400,
        headers: corsHeaders,
      });
    }

    // Flutter 쪽에서 보낼 키:
    // - 기존 코드: { "image": base64 }
    // - 네가 방금 쓴 함수: { "imageBase64": base64 }
    // 둘 다 지원하게 처리
    const imageBase64 =
      (body as any).imageBase64 ?? (body as any).image;

    if (!imageBase64 || typeof imageBase64 !== "string") {
      return new Response("imageBase64 (or image) is required", {
        status: 400,
        headers: corsHeaders,
      });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      console.error("OPENAI_API_KEY not set");
      return new Response("Server config error", {
        status: 500,
        headers: corsHeaders,
      });
    }

    // 4) OpenAI 호출
    const openaiRes = await fetch(
      "https://api.openai.com/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content:
                "You are a helpful receipt analyzer for a Korean bookkeeping app. Always return ONLY a JSON object. No explanations.",
            },
            {
              role: "user",
              content: [
                {
                  type: "text",
                  text: `
이 영수증 사진을 분석해서 아래 JSON 형식으로만 응답해줘.

{
  "storeName": "상호명",
  "date": "YYYY-MM-DD",
  "amount": 숫자(원 단위, 정수),
  "category": "식비/교통/쇼핑/비즈니스/기타 중 하나",
  "memo": "간단한 품목 요약",
  "type": "expense",
  "isPaid": true
}

- 날짜나 금액을 정확히 알 수 없으면:
  - date 는 오늘 날짜(YYYY-MM-DD)로
  - amount 는 0으로 채워.
- 키 이름은 꼭 위 JSON과 정확히 동일하게 사용해.
`,
                },
                {
                  type: "image_url",
                  image_url: {
                    url: `data:image/jpeg;base64,${imageBase64}`,
                  },
                },
              ],
            },
          ],
          max_tokens: 500,
          response_format: { type: "json_object" },
        }),
      },
    );

    if (!openaiRes.ok) {
      const errText = await openaiRes.text();
      console.error("OpenAI error:", openaiRes.status, errText);
      return new Response(
        JSON.stringify({
          error: "openai_error",
          status: openaiRes.status,
          detail: errText,
        }),
        {
          status: 500,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const data = await openaiRes.json();

    // OpenAI 응답에서 content 꺼내기
    let content = data?.choices?.[0]?.message?.content ?? "{}";

    // 혹시 content 가 배열(멀티 파트)로 올 수도 있어서 방어코드
    if (Array.isArray(content)) {
      const textPart = content.find(
        (p: any) => p.type === "text",
      );
      content = textPart?.text ?? "{}";
    }

    let jsonResult: unknown;
    try {
      jsonResult = JSON.parse(content);
    } catch (_e) {
      // 혹시 이미 JSON 객체로 올 경우 그대로 넘김
      jsonResult = content;
    }

    return new Response(JSON.stringify(jsonResult), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });
  } catch (e) {
    console.error("Function error:", e);
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(e),
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});