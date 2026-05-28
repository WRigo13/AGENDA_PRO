-- ═══════════════════════════════════════════════════════
--  AGENDAPRO — Schema Supabase
--  Execute no SQL Editor do Supabase
-- ═══════════════════════════════════════════════════════

-- 1. NEGÓCIOS (multi-tenant)
CREATE TABLE IF NOT EXISTS negocios (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  tipo        TEXT DEFAULT 'salao',
  owner       UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  plan        TEXT DEFAULT 'free',
  status      TEXT DEFAULT 'ativo',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. PROFISSIONAIS
CREATE TABLE IF NOT EXISTS profissionais (
  id           TEXT PRIMARY KEY,
  company_id   TEXT REFERENCES negocios(id) ON DELETE CASCADE,
  nome         TEXT NOT NULL,
  especialidade TEXT,
  telefone     TEXT,
  email        TEXT,
  comissao     INTEGER DEFAULT 40,
  cor          TEXT DEFAULT '#7C3AED',
  ativo        BOOLEAN DEFAULT true,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 3. SERVIÇOS
CREATE TABLE IF NOT EXISTS servicos (
  id          TEXT PRIMARY KEY,
  company_id  TEXT REFERENCES negocios(id) ON DELETE CASCADE,
  nome        TEXT NOT NULL,
  categoria   TEXT DEFAULT 'outros',
  duracao     INTEGER DEFAULT 60,
  preco       NUMERIC(10,2) DEFAULT 0,
  comissao    INTEGER DEFAULT 40,
  descricao   TEXT,
  ativo       BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
  id          TEXT PRIMARY KEY,
  company_id  TEXT REFERENCES negocios(id) ON DELETE CASCADE,
  nome        TEXT NOT NULL,
  telefone    TEXT,
  email       TEXT,
  nascimento  DATE,
  origem      TEXT,
  obs         TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 5. AGENDAMENTOS
CREATE TABLE IF NOT EXISTS agendamentos (
  id           TEXT PRIMARY KEY,
  company_id   TEXT REFERENCES negocios(id) ON DELETE CASCADE,
  data         DATE NOT NULL,
  hora         TIME NOT NULL,
  cliente      TEXT NOT NULL,
  telefone     TEXT,
  servico      TEXT,
  servico_nome TEXT,
  profissional TEXT,
  prof_nome    TEXT,
  valor        NUMERIC(10,2) DEFAULT 0,
  forma        TEXT DEFAULT 'pix',
  status       TEXT DEFAULT 'pendente',
  obs          TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 6. CONFIGS DO NEGÓCIO
CREATE TABLE IF NOT EXISTS configs_negocio (
  id          TEXT PRIMARY KEY,
  company_id  TEXT REFERENCES negocios(id) ON DELETE CASCADE UNIQUE,
  config      JSONB DEFAULT '{}',
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── RLS ────────────────────────────────────────────────────
ALTER TABLE negocios       ENABLE ROW LEVEL SECURITY;
ALTER TABLE profissionais  ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicos       ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE agendamentos   ENABLE ROW LEVEL SECURITY;
ALTER TABLE configs_negocio ENABLE ROW LEVEL SECURITY;

-- Políticas (acesso autenticado)
DROP POLICY IF EXISTS "acesso_negocios"        ON negocios;
DROP POLICY IF EXISTS "acesso_profissionais"   ON profissionais;
DROP POLICY IF EXISTS "acesso_servicos"        ON servicos;
DROP POLICY IF EXISTS "acesso_clientes"        ON clientes;
DROP POLICY IF EXISTS "acesso_agendamentos"    ON agendamentos;
DROP POLICY IF EXISTS "acesso_configs_negocio" ON configs_negocio;

CREATE POLICY "acesso_negocios"        ON negocios        FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acesso_profissionais"   ON profissionais   FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acesso_servicos"        ON servicos        FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acesso_clientes"        ON clientes        FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acesso_agendamentos"    ON agendamentos    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "acesso_configs_negocio" ON configs_negocio FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── ÍNDICES ────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_agend_company_data  ON agendamentos(company_id, data);
CREATE INDEX IF NOT EXISTS idx_agend_status        ON agendamentos(status);
CREATE INDEX IF NOT EXISTS idx_clientes_company    ON clientes(company_id);
CREATE INDEX IF NOT EXISTS idx_servicos_company    ON servicos(company_id);
CREATE INDEX IF NOT EXISTS idx_profissionais_company ON profissionais(company_id);

-- ── CONFIRMAR ──────────────────────────────────────────────
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('negocios','profissionais','servicos','clientes','agendamentos','configs_negocio')
ORDER BY table_name;
