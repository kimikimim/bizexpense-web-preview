// Middle East receipt OCR — international prompt (decimals, English categories).
//
// Deployed to the ME project under the name `receipt-ocr` (same name the client
// calls; the KR project keeps its own Korean-prompt version). Tuned for AED/SAR
// receipts: amount is a decimal (fils/halala preserved), categories in English.
//
// Requires the OPENAI_API_KEY secret to be set on the ME project:
//   supabase secrets set OPENAI_API_KEY=... --project-ref qdmyyifmgarfanzqbdpw
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  try {
    const body = await req.json().catch(() => null);
    if (!body || typeof body !== "object") {
      return new Response("Invalid JSON body", { status: 400, headers: corsHeaders });
    }
    const imageBase64 = (body as any).imageBase64 ?? (body as any).image;
    if (!imageBase64 || typeof imageBase64 !== "string") {
      return new Response("imageBase64 (or image) is required", { status: 400, headers: corsHeaders });
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      console.error("OPENAI_API_KEY not set");
      return new Response("Server config error", { status: 500, headers: corsHeaders });
    }

    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
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
              "You analyze receipts for a Middle East bookkeeping app. Always return ONLY a JSON object. No explanations.",
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: `Analyze this receipt image and respond ONLY with this JSON shape:

{
  "storeName": "merchant name",
  "date": "YYYY-MM-DD",
  "amount": number (the total as printed, keep decimals, e.g. 10.50),
  "category": one of "Food/Transport/Shopping/Business/Other",
  "memo": "short item summary",
  "type": "expense",
  "isPaid": true
}

Rules:
- amount is the printed grand total INCLUDING VAT, as a decimal number (do not round; keep fils/halala).
- If date or amount is unreadable: date = today (YYYY-MM-DD), amount = 0.
- Use exactly the JSON keys above.`,
              },
              {
                type: "image_url",
                image_url: { url: `data:image/jpeg;base64,${imageBase64}` },
              },
            ],
          },
        ],
        max_tokens: 500,
        response_format: { type: "json_object" },
      }),
    });

    if (!openaiRes.ok) {
      const errText = await openaiRes.text();
      console.error("OpenAI error:", openaiRes.status, errText);
      return new Response(
        JSON.stringify({ error: "openai_error", status: openaiRes.status, detail: errText }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const data = await openaiRes.json();
    let content = data?.choices?.[0]?.message?.content ?? "{}";
    if (Array.isArray(content)) {
      const textPart = content.find((p: any) => p.type === "text");
      content = textPart?.text ?? "{}";
    }
    let jsonResult: unknown;
    try {
      jsonResult = JSON.parse(content);
    } catch (_e) {
      jsonResult = content;
    }
    return new Response(JSON.stringify(jsonResult), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Function error:", e);
    return new Response(
      JSON.stringify({ error: "internal_error", message: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
