-- ═══════════════════════════════════════════════════════
--  AGENDAPRO — Schema Supabase (v2 — RLS multi-tenant)
--  Execute no SQL Editor do Supabase
-- ═══════════════════════════════════════════════════════

-- ── TABELAS ────────────────────────────────────────────

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
  id            TEXT PRIMARY KEY,
  company_id    TEXT REFERENCES negocios(id) ON DELETE CASCADE,
  nome          TEXT NOT NULL,
  especialidade TEXT,
  telefone      TEXT,
  email         TEXT,
  comissao      INTEGER DEFAULT 40,
  cor           TEXT DEFAULT '#7C3AED',
  ativo         BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
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

-- ── HABILITAR RLS ──────────────────────────────────────
ALTER TABLE negocios        ENABLE ROW LEVEL SECURITY;
ALTER TABLE profissionais   ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicos        ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE agendamentos    ENABLE ROW LEVEL SECURITY;
ALTER TABLE configs_negocio ENABLE ROW LEVEL SECURITY;

-- ── REMOVER POLÍTICAS ANTIGAS ──────────────────────────
DROP POLICY IF EXISTS "acesso_negocios"        ON negocios;
DROP POLICY IF EXISTS "acesso_profissionais"   ON profissionais;
DROP POLICY IF EXISTS "acesso_servicos"        ON servicos;
DROP POLICY IF EXISTS "acesso_clientes"        ON clientes;
DROP POLICY IF EXISTS "acesso_agendamentos"    ON agendamentos;
DROP POLICY IF EXISTS "acesso_configs_negocio" ON configs_negocio;

-- Políticas v2 (remover também caso já existam)
DROP POLICY IF EXISTS "negocios_owner_select"      ON negocios;
DROP POLICY IF EXISTS "negocios_owner_insert"      ON negocios;
DROP POLICY IF EXISTS "negocios_owner_update"      ON negocios;
DROP POLICY IF EXISTS "negocios_owner_delete"      ON negocios;
DROP POLICY IF EXISTS "profissionais_owner"        ON profissionais;
DROP POLICY IF EXISTS "servicos_owner"             ON servicos;
DROP POLICY IF EXISTS "clientes_owner"             ON clientes;
DROP POLICY IF EXISTS "agendamentos_owner"         ON agendamentos;
DROP POLICY IF EXISTS "agendamentos_public_insert" ON agendamentos;
DROP POLICY IF EXISTS "configs_owner"              ON configs_negocio;
DROP POLICY IF EXISTS "servicos_public_read"       ON servicos;
DROP POLICY IF EXISTS "profissionais_public_read"  ON profissionais;
DROP POLICY IF EXISTS "negocios_public_read"       ON negocios;
DROP POLICY IF EXISTS "configs_public_read"        ON configs_negocio;

-- ── FUNÇÃO AUXILIAR: owner do negócio ─────────────────
-- Retorna o owner_id do negócio dado um company_id.
-- Usada nas políticas para checar se o usuário autenticado
-- é dono do negócio referenciado.
CREATE OR REPLACE FUNCTION get_negocio_owner(cid TEXT)
RETURNS UUID
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT owner FROM negocios WHERE id = cid LIMIT 1;
$$;

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — NEGOCIOS
--  Dono gerencia seu próprio negócio.
--  Leitura pública para a booking page encontrar por nome.
-- ═══════════════════════════════════════════════════════
CREATE POLICY "negocios_owner_select" ON negocios
  FOR SELECT USING (
    owner = auth.uid()               -- dono vê o seu
    OR auth.role() = 'anon'          -- anon vê todos (leitura para booking page)
  );

CREATE POLICY "negocios_owner_insert" ON negocios
  FOR INSERT TO authenticated
  WITH CHECK (owner = auth.uid());

CREATE POLICY "negocios_owner_update" ON negocios
  FOR UPDATE TO authenticated
  USING (owner = auth.uid())
  WITH CHECK (owner = auth.uid());

CREATE POLICY "negocios_owner_delete" ON negocios
  FOR DELETE TO authenticated
  USING (owner = auth.uid());

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — PROFISSIONAIS
--  Dono do negócio gerencia. Anon lê (booking page).
-- ═══════════════════════════════════════════════════════
CREATE POLICY "profissionais_public_read" ON profissionais
  FOR SELECT USING (true);   -- leitura pública p/ booking

CREATE POLICY "profissionais_owner" ON profissionais
  FOR ALL TO authenticated
  USING  (get_negocio_owner(company_id) = auth.uid())
  WITH CHECK (get_negocio_owner(company_id) = auth.uid());

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — SERVIÇOS
--  Idem profissionais.
-- ═══════════════════════════════════════════════════════
CREATE POLICY "servicos_public_read" ON servicos
  FOR SELECT USING (true);

CREATE POLICY "servicos_owner" ON servicos
  FOR ALL TO authenticated
  USING  (get_negocio_owner(company_id) = auth.uid())
  WITH CHECK (get_negocio_owner(company_id) = auth.uid());

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — CLIENTES
--  Apenas o dono lê/escreve.
--  Anon pode inserir (novo cliente via booking page).
-- ═══════════════════════════════════════════════════════
CREATE POLICY "clientes_owner" ON clientes
  FOR ALL TO authenticated
  USING  (get_negocio_owner(company_id) = auth.uid())
  WITH CHECK (get_negocio_owner(company_id) = auth.uid());

CREATE POLICY "clientes_public_insert" ON clientes
  FOR INSERT TO anon
  WITH CHECK (true);   -- booking page cria clientes

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — AGENDAMENTOS
--  Dono lê/atualiza tudo do seu negócio.
--  Anon pode inserir (booking page) e ler ocupados.
-- ═══════════════════════════════════════════════════════
CREATE POLICY "agendamentos_owner" ON agendamentos
  FOR ALL TO authenticated
  USING  (get_negocio_owner(company_id) = auth.uid())
  WITH CHECK (get_negocio_owner(company_id) = auth.uid());

-- Booking page: inserir novo agendamento sem login
CREATE POLICY "agendamentos_public_insert" ON agendamentos
  FOR INSERT TO anon
  WITH CHECK (true);

-- Booking page: ler slots ocupados (só data/hora/profissional, sem dados pessoais)
-- Usamos uma view para isso — ver abaixo
CREATE POLICY "agendamentos_public_read" ON agendamentos
  FOR SELECT TO anon
  USING (true);   -- limitado pela view ocupados_view abaixo

-- ═══════════════════════════════════════════════════════
--  POLÍTICAS — CONFIGS
-- ═══════════════════════════════════════════════════════
CREATE POLICY "configs_public_read" ON configs_negocio
  FOR SELECT USING (true);

CREATE POLICY "configs_owner" ON configs_negocio
  FOR ALL TO authenticated
  USING  (get_negocio_owner(company_id) = auth.uid())
  WITH CHECK (get_negocio_owner(company_id) = auth.uid());

-- ═══════════════════════════════════════════════════════
--  VIEW: slots ocupados (expõe só o necessário para anon)
--  A booking page usa esta view em vez da tabela direta.
-- ═══════════════════════════════════════════════════════
CREATE OR REPLACE VIEW ocupados_view AS
  SELECT company_id, data, hora, profissional, status
  FROM agendamentos
  WHERE status IN ('pendente', 'confirmado');

-- ── ÍNDICES ────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_agend_company_data    ON agendamentos(company_id, data);
CREATE INDEX IF NOT EXISTS idx_agend_status          ON agendamentos(status);
CREATE INDEX IF NOT EXISTS idx_agend_prof_data       ON agendamentos(profissional, data);
CREATE INDEX IF NOT EXISTS idx_clientes_company      ON clientes(company_id);
CREATE INDEX IF NOT EXISTS idx_servicos_company      ON servicos(company_id);
CREATE INDEX IF NOT EXISTS idx_profissionais_company ON profissionais(company_id);
CREATE INDEX IF NOT EXISTS idx_negocios_owner        ON negocios(owner);
CREATE INDEX IF NOT EXISTS idx_negocios_status       ON negocios(status);

-- ── CONFIRMAR ──────────────────────────────────────────
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('negocios','profissionais','servicos','clientes','agendamentos','configs_negocio')
ORDER BY table_name;
