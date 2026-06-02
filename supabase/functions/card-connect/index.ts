import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Codef 기관코드 매핑
const COMPANY_CODES: Record<string, string> = {
  "삼성카드": "0301",
  "KB국민카드": "0381",
  "신한카드": "0088",
  "현대카드": "0329",
  "롯데카드": "0030",
  "우리카드": "0020",
  "하나카드": "0081",
  "BC카드": "0361",
  "NH농협카드": "0011",
  "씨티카드": "0027",
};

async function getCodefToken(): Promise<string> {
  const clientId = Deno.env.get("CODEF_CLIENT_ID")!;
  const clientSecret = Deno.env.get("CODEF_CLIENT_SECRET")!;
  const credentials = btoa(`${clientId}:${clientSecret}`);

  const res = await fetch("https://oauth.codef.io/oauth/token", {
    method: "POST",
    headers: {
      "Authorization": `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials&scope=read",
  });

  if (!res.ok) {
    throw new Error(`Codef OAuth 실패: ${res.status}`);
  }
  const data = await res.json();
  return data.access_token;
}

async function getCodefPublicKey(token: string): Promise<string> {
  const res = await fetch("https://development.codef.io/v1/util/public-key", {
    headers: { "Authorization": `Bearer ${token}` },
  });
  if (!res.ok) throw new Error("공개키 조회 실패");
  const data = await res.json();
  return data.publicKey;
}

// RSA 암호화 (SubtleCrypto 사용)
async function encryptRSA(plaintext: string, publicKeyPem: string): Promise<string> {
  const pemBody = publicKeyPem
    .replace("-----BEGIN PUBLIC KEY-----", "")
    .replace("-----END PUBLIC KEY-----", "")
    .replace(/\s/g, "");

  const keyData = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "spki",
    keyData.buffer,
    { name: "RSA-OAEP", hash: "SHA-1" },
    false,
    ["encrypt"],
  );

  const encoded = new TextEncoder().encode(plaintext);
  const encrypted = await crypto.subtle.encrypt({ name: "RSA-OAEP" }, cryptoKey, encoded);
  return btoa(String.fromCharCode(...new Uint8Array(encrypted)));
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // JWT에서 user_id 추출
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    const { data: { user }, error: userError } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
    if (userError || !user) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    const { cardId, loginId, loginPassword } = await req.json();

    // 카드 정보 조회
    const { data: card, error: cardError } = await supabase
      .from("cards")
      .select("*")
      .eq("id", cardId)
      .eq("user_id", user.id)
      .single();

    if (cardError || !card) {
      return new Response(JSON.stringify({ error: "카드를 찾을 수 없습니다." }), {
        status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Codef 토큰 및 공개키 획득
    const token = await getCodefToken();
    const publicKey = await getCodefPublicKey(token);

    // 비밀번호 RSA 암호화
    const encryptedPassword = await encryptRSA(loginPassword, publicKey);

    // Codef 연결계정 등록
    const codefRes = await fetch("https://development.codef.io/v1/account/create", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        countryCode: "KR",
        businessType: "CD",
        clientType: "P",
        organization: card.company_code,
        loginType: "1",
        id: loginId,
        password: encryptedPassword,
      }),
    });

    const codefData = await codefRes.json();

    if (!codefRes.ok || codefData.result?.code !== "CF-00000") {
      return new Response(
        JSON.stringify({ error: "카드 연동 실패", detail: codefData.result?.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const connectorId = codefData.data?.connectorList?.[0]?.connectorId;

    // connectorId 저장 (비밀번호는 저장 안 함)
    await supabase
      .from("cards")
      .update({ connector_id: connectorId })
      .eq("id", cardId);

    return new Response(
      JSON.stringify({ success: true, connectorId }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error(e);
    return new Response(
      JSON.stringify({ error: "서버 오류", message: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
