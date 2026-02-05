-- =============================================
-- Mendel GTM API - Schema V3
-- Complete knowledge_base migration
-- =============================================

-- 1. SALES_PLAYBOOK - Battlecard, pitch, discovery questions, proof points
CREATE TABLE IF NOT EXISTS sales_playbook (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,

  -- Pitches by country/region
  pitch_global TEXT,                    -- 30-second pitch for all countries
  pitch_mexico TEXT,                    -- Mexico-specific addition
  pitch_short TEXT,                     -- One-liner

  -- Target customer summary
  target_customer JSONB DEFAULT '{}',   -- {size, geography, industries, pain}

  -- Discovery questions
  discovery_questions TEXT[],           -- Array of questions to ask

  -- Proof points
  proof_points JSONB DEFAULT '{}',      -- {client_name: result, ...}

  -- Quick reference competitive positioning
  competitive_summary JSONB DEFAULT '{}', -- {competitor: our_advantage}

  -- Top objections quick reference
  top_objections JSONB DEFAULT '{}',    -- {objection: handle}

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id)
);

-- 2. PRODUCT_FEATURES - Detailed product capabilities
CREATE TABLE IF NOT EXISTS product_features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  slug VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description TEXT,

  -- How it works (step by step)
  how_it_works TEXT[],

  -- Key metrics/results
  metrics JSONB DEFAULT '{}',           -- {metric_name: {before, after, improvement}}

  -- Why it matters
  why_it_matters TEXT,

  -- Availability by country
  availability_by_country JSONB DEFAULT '{}', -- {MX: true, AR: false, note: "..."}

  -- Competitive advantage
  competitive_advantage JSONB DEFAULT '{}', -- {competitor: their_capability}

  -- Related personas (who cares most)
  related_personas TEXT[],

  is_addon BOOLEAN DEFAULT false,       -- Is this an upsell/add-on module?

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, slug)
);

-- 3. EMAIL_TEMPLATES - Follow-up templates and detailed snippets
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  slug VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  template_type VARCHAR(50) NOT NULL,   -- first_contact, signal_trigger, case_study, validation, followup, breakup

  -- When to use
  when_to_use TEXT,

  -- Template structure
  template_structure TEXT,              -- The actual template with {variables}

  -- Example filled in
  example TEXT,

  -- Sequence order (for follow-ups)
  sequence_order INTEGER,
  days_after_previous INTEGER,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, slug)
);

-- 4. Update COMPETITORS - Add when_we_win and when_they_win
ALTER TABLE competitors
ADD COLUMN IF NOT EXISTS positioning TEXT,
ADD COLUMN IF NOT EXISTS when_we_win TEXT[],
ADD COLUMN IF NOT EXISTS when_they_win TEXT[],
ADD COLUMN IF NOT EXISTS how_we_work_together TEXT;

-- 5. Update PERSONAS - Add detailed fields
ALTER TABLE personas
ADD COLUMN IF NOT EXISTS responsibilities TEXT[],
ADD COLUMN IF NOT EXISTS value_props_by_country JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS process_before_after JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS success_metrics JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS relationship_to_others JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS is_decision_maker BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS email_snippets JSONB DEFAULT '{}';

-- 6. Update OBJECTIONS - Add more detail
ALTER TABLE objections
ADD COLUMN IF NOT EXISTS trigger_questions TEXT[];

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sales_playbook_client ON sales_playbook(client_id);
CREATE INDEX IF NOT EXISTS idx_product_features_client ON product_features(client_id);
CREATE INDEX IF NOT EXISTS idx_product_features_slug ON product_features(slug);
CREATE INDEX IF NOT EXISTS idx_email_templates_client ON email_templates(client_id);
CREATE INDEX IF NOT EXISTS idx_email_templates_type ON email_templates(template_type);

-- Triggers for updated_at
CREATE OR REPLACE TRIGGER update_sales_playbook_updated_at
  BEFORE UPDATE ON sales_playbook
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_product_features_updated_at
  BEFORE UPDATE ON product_features
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_email_templates_updated_at
  BEFORE UPDATE ON email_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
