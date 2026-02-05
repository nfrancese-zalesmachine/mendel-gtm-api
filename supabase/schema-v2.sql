-- =============================================
-- Mendel GTM API - Schema V2
-- Tablas adicionales para contexto completo
-- =============================================

-- 1. COMPETITORS - Benchmark competitivo
CREATE TABLE IF NOT EXISTS competitors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(50) DEFAULT 'direct', -- direct, indirect
  target_segment VARCHAR(100), -- SMB, Enterprise, etc.
  features JSONB DEFAULT '{}', -- comparación de features
  our_advantage TEXT, -- ventaja principal de nuestro cliente vs este competidor
  website VARCHAR(255),
  linkedin_url VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, name)
);

-- 2. OBJECTIONS - Objeciones y respuestas
CREATE TABLE IF NOT EXISTS objections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  objection TEXT NOT NULL, -- la objeción del prospecto
  category VARCHAR(50), -- price, timing, competition, implementation, trust
  response TEXT NOT NULL, -- cómo responder
  evidence TEXT, -- evidencia o caso que respalda
  persona_slugs TEXT[], -- personas a las que aplica (NULL = todas)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CASE_STUDIES - Casos de éxito
CREATE TABLE IF NOT EXISTS case_studies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  company_name VARCHAR(200) NOT NULL,
  industry VARCHAR(100),
  company_size VARCHAR(50), -- "10,000+", "1,000-5,000", etc.
  buyer_persona VARCHAR(100), -- CFO, Controller, etc.
  acquisition_channel VARCHAR(100), -- Outbound, Inbound, Referral, Partner
  problem TEXT, -- qué intentaba resolver
  before_state TEXT, -- cómo resolvían antes
  main_pain TEXT, -- dolor principal
  outcome TEXT, -- resultados logrados
  metrics JSONB DEFAULT '{}', -- métricas específicas {"recovery_increase": "30%", "deductibility": "90%"}
  objections_faced TEXT[], -- objeciones que tuvieron antes de comprar
  is_public BOOLEAN DEFAULT true, -- si se puede mencionar públicamente
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. SIGNALS - Señales de oportunidad (triggers de compra)
CREATE TABLE IF NOT EXISTS signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL, -- fiscal, growth, digital, friction, travel
  signal_name VARCHAR(200) NOT NULL,
  description TEXT,
  why_relevant TEXT, -- por qué es una buena señal
  how_to_detect TEXT, -- cómo detectarla
  priority INTEGER DEFAULT 5, -- 1-10, 10 = más importante
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_competitors_client ON competitors(client_id);
CREATE INDEX IF NOT EXISTS idx_objections_client ON objections(client_id);
CREATE INDEX IF NOT EXISTS idx_objections_category ON objections(category);
CREATE INDEX IF NOT EXISTS idx_case_studies_client ON case_studies(client_id);
CREATE INDEX IF NOT EXISTS idx_case_studies_industry ON case_studies(industry);
CREATE INDEX IF NOT EXISTS idx_signals_client ON signals(client_id);
CREATE INDEX IF NOT EXISTS idx_signals_category ON signals(category);

-- Triggers para updated_at
CREATE OR REPLACE TRIGGER update_competitors_updated_at
  BEFORE UPDATE ON competitors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_objections_updated_at
  BEFORE UPDATE ON objections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_case_studies_updated_at
  BEFORE UPDATE ON case_studies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_signals_updated_at
  BEFORE UPDATE ON signals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
