-- ============================================
-- Mendel GTM API - Supabase Schema
-- Multi-tenant architecture for GTM context
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CLIENTS TABLE
-- Each client (company) using the GTM API
-- ============================================
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug VARCHAR(50) UNIQUE NOT NULL, -- 'mendel', 'acme', etc.
  name VARCHAR(255) NOT NULL,
  description TEXT,
  api_key VARCHAR(255) UNIQUE, -- Optional: for client-specific API keys
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PERSONAS TABLE
-- Buyer personas for each client
-- ============================================
CREATE TABLE personas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  slug VARCHAR(50) NOT NULL, -- 'CFO', 'Controller', etc.
  titles TEXT[] NOT NULL, -- Array of job titles
  role VARCHAR(100),
  reports_to VARCHAR(100),
  pains TEXT[] NOT NULL,
  cares_about TEXT[] NOT NULL,
  questions TEXT[] NOT NULL,
  objections JSONB, -- Key-value pairs of objection -> response
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, slug)
);

-- ============================================
-- COUNTRIES TABLE
-- Value props by country for each client
-- ============================================
CREATE TABLE countries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  code VARCHAR(5) NOT NULL, -- 'MX', 'AR', 'CL', etc.
  name VARCHAR(100) NOT NULL,
  specific_value_props TEXT[] NOT NULL,
  unique_features TEXT[],
  pain_emphasis TEXT,
  compliance VARCHAR(50), -- 'SAT', 'AFIP', 'SII', etc.
  metrics JSONB, -- Country-specific metrics
  note TEXT, -- Special notes (e.g., "NO SAT recovery")
  scoring_weight INTEGER DEFAULT 3, -- For lead scoring
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, code)
);

-- ============================================
-- INDUSTRIES TABLE
-- Industry snippets for email personalization
-- ============================================
CREATE TABLE industries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  slug VARCHAR(50) NOT NULL, -- 'retail', 'logistica', etc.
  name VARCHAR(100) NOT NULL,
  tier INTEGER DEFAULT 2, -- 1 = best fit, 2 = good fit
  pains TEXT[] NOT NULL,
  reference_clients TEXT[], -- Reference clients for this industry
  reason TEXT, -- Why this industry is a fit
  scoring_weight INTEGER DEFAULT 3,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, slug)
);

-- ============================================
-- GLOBAL CONFIG TABLE
-- Global value props and settings per client
-- ============================================
CREATE TABLE global_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE UNIQUE,
  core_value_props TEXT[] NOT NULL,
  differentiators JSONB, -- vs_clara, vs_jeeves, etc.
  reference_clients TEXT[] NOT NULL,
  features JSONB, -- cards, control, approvals, etc.
  company_description TEXT, -- For prompts
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ICP CONFIG TABLE
-- ICP criteria and scoring for each client
-- ============================================
CREATE TABLE icp_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE UNIQUE,
  firmographics JSONB NOT NULL, -- size, geography, structure
  qualifying_signals JSONB NOT NULL, -- include, exclude arrays
  scoring_criteria JSONB NOT NULL, -- company_size, country, industry weights
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- EMAIL FRAMEWORK TABLE
-- Email generation guidelines per client
-- ============================================
CREATE TABLE email_framework (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE UNIQUE,
  principles JSONB NOT NULL, -- tone, never_salesy, etc.
  structure JSONB NOT NULL, -- max_words, one_idea, cta
  dont_do TEXT[] NOT NULL,
  templates JSONB, -- open_question, signal_trigger, etc.
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_personas_client ON personas(client_id);
CREATE INDEX idx_personas_slug ON personas(slug);
CREATE INDEX idx_countries_client ON countries(client_id);
CREATE INDEX idx_countries_code ON countries(code);
CREATE INDEX idx_industries_client ON industries(client_id);
CREATE INDEX idx_industries_slug ON industries(slug);
CREATE INDEX idx_clients_slug ON clients(slug);
CREATE INDEX idx_clients_api_key ON clients(api_key);

-- ============================================
-- UPDATED_AT TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personas_updated_at BEFORE UPDATE ON personas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_countries_updated_at BEFORE UPDATE ON countries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_industries_updated_at BEFORE UPDATE ON industries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_global_config_updated_at BEFORE UPDATE ON global_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_icp_config_updated_at BEFORE UPDATE ON icp_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_email_framework_updated_at BEFORE UPDATE ON email_framework
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Enable for production security
-- ============================================
-- ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE industries ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE global_config ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE icp_config ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE email_framework ENABLE ROW LEVEL SECURITY;

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

-- Full context view for a client
CREATE OR REPLACE VIEW client_full_context AS
SELECT
  c.id as client_id,
  c.slug as client_slug,
  c.name as client_name,
  gc.core_value_props,
  gc.differentiators,
  gc.reference_clients,
  gc.features,
  gc.company_description,
  ic.firmographics,
  ic.qualifying_signals,
  ic.scoring_criteria,
  ef.principles as email_principles,
  ef.structure as email_structure,
  ef.dont_do as email_dont_do,
  ef.templates as email_templates
FROM clients c
LEFT JOIN global_config gc ON c.id = gc.client_id
LEFT JOIN icp_config ic ON c.id = ic.client_id
LEFT JOIN email_framework ef ON c.id = ef.client_id
WHERE c.is_active = true;
