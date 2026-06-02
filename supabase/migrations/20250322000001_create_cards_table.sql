-- 카드/계좌 등록 테이블
CREATE TABLE IF NOT EXISTS cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL,                    -- 사용자가 붙인 별명 (예: "내 삼성카드")
  company_code TEXT NOT NULL,                -- Codef 기관코드 (예: "0301")
  company_name TEXT NOT NULL,                -- 카드사 이름 (예: "삼성카드")
  last_four TEXT,                            -- 카드 끝 4자리 (선택)
  connector_id TEXT,                         -- Codef 연결계정 ID (credentials는 Codef에만 저장)
  last_synced_at TIMESTAMPTZ,               -- 마지막 동기화 시각
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS 활성화
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cards_own" ON cards
  FOR ALL USING (auth.uid() = user_id);

-- 인덱스
CREATE INDEX idx_cards_user_id ON cards(user_id);
