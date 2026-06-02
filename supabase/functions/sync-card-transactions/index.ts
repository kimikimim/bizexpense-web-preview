import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
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

  if (!res.ok) throw new Error(`Codef OAuth 실패: ${res.status}`);
  const data = await res.json();
  return data.access_token;
}

// 카테고리 자동 분류 (간단한 키워드 매핑)
function guessCategory(storeName: string): string {
  const name = storeName.toLowerCase();
  if (/스타벅스|커피|카페|이디야|투썸|할리스/.test(name)) return "카페";
  if (/맥도날드|버거킹|롯데리아|kfc|치킨|피자|파파존스|도미노|배민|쿠팡이츠|요기요/.test(name)) return "식비";
  if (/편의점|gs25|cu|세븐|미니스톱|이마트|홈플|코스트코|마켓컬리/.test(name)) return "식비";
  if (/지하철|버스|택시|카카오t|우버|kt|ktx|srt/.test(name)) return "교통";
  if (/주유|sk에너지|gs칼텍스|현대오일/.test(name)) return "교통";
  if (/병원|의원|약국|치과|한의원/.test(name)) return "의료";
  if (/학원|교육|책|yes24|교보/.test(name)) return "교육";
  if (/쇼핑|무신사|쿠팡|네이버|11번가|gmarket|옥션|올리브영/.test(name)) return "쇼핑";
  if (/통신|kt|sk텔레콤|lg유플러스|핸드폰/.test(name)) return "통신";
  if (/호텔|모텔|숙박|에어비앤비/.test(name)) return "숙박";
  if (/골프|헬스|피트니스|스포츠|수영/.test(name)) return "여가";
  return "기타";
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    const { data: { user }, error: userError } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
    if (userError || !user) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    // cardId 없으면 모든 카드 동기화
    const body = await req.json().catch(() => ({}));
    const targetCardId = body.cardId ?? null;

    const cardQuery = supabase
      .from("cards")
      .select("*")
      .eq("user_id", user.id)
      .eq("is_active", true)
      .not("connector_id", "is", null);

    if (targetCardId) cardQuery.eq("id", targetCardId);

    const { data: cards, error: cardsError } = await cardQuery;
    if (cardsError || !cards?.length) {
      return new Response(
        JSON.stringify({ success: true, synced: 0, message: "동기화할 카드 없음" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const token = await getCodefToken();

    // 동기화 기간: 최근 3개월
    const now = new Date();
    const endDate = now.toISOString().slice(0, 10).replace(/-/g, "");
    const startDate = new Date(now.setMonth(now.getMonth() - 3))
      .toISOString().slice(0, 10).replace(/-/g, "");

    let totalSynced = 0;

    for (const card of cards) {
      try {
        const txRes = await fetch(
          "https://development.codef.io/v1/kr/card/p/account/transaction-list",
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${token}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              connectorId: card.connector_id,
              organization: card.company_code,
              startDate,
              endDate,
              orderBy: "0",
            }),
          },
        );

        if (!txRes.ok) {
          console.error(`카드 ${card.id} 동기화 실패: ${txRes.status}`);
          continue;
        }

        const txData = await txRes.json();
        const transactions = txData.data?.resTrHistoryList ?? [];

        for (const tx of transactions) {
          const approvalNumber = tx.resApprovalNo ?? "";
          const amount = parseInt(tx.resPayAmt ?? "0", 10);
          const storeName = tx.resMerchantName ?? "알 수 없음";
          const dateStr = tx.resApprovalDate ?? "";

          // 날짜 파싱 (YYYYMMDD → DateTime)
          let txDate = new Date().toISOString();
          if (dateStr.length === 8) {
            txDate = `${dateStr.slice(0, 4)}-${dateStr.slice(4, 6)}-${dateStr.slice(6, 8)}T00:00:00.000Z`;
          }

          // 승인번호로 중복 체크
          if (approvalNumber) {
            const { data: existing } = await supabase
              .from("transactions")
              .select("id")
              .eq("user_id", user.id)
              .eq("approval_number", approvalNumber)
              .maybeSingle();

            if (existing) continue; // 이미 있으면 스킵
          }

          // transactions 테이블에 저장
          await supabase.from("transactions").insert({
            user_id: user.id,
            store_name: storeName,
            amount: amount,
            transaction_date: txDate,
            category: guessCategory(storeName),
            method: card.company_name,
            transaction_type: "expense",
            is_paid: true,
            account_id: card.id,
            approval_number: approvalNumber,
            is_tax_deductible: true,
            memo: `${card.nickname} 자동 동기화`,
          });

          totalSynced++;
        }

        // last_synced_at 업데이트
        await supabase
          .from("cards")
          .update({ last_synced_at: new Date().toISOString() })
          .eq("id", card.id);
      } catch (cardErr) {
        console.error(`카드 ${card.id} 처리 중 오류:`, cardErr);
      }
    }

    return new Response(
      JSON.stringify({ success: true, synced: totalSynced }),
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
