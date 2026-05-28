# 📅 AgendaPro — Sistema de Agendamentos

Sistema SaaS de agendamentos para salões, barbearias, clínicas e profissionais autônomos.

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `index.html` | App principal (ERP / painel de gestão) |
| `landing.html` | Landing page de vendas |
| `schema.sql` | Schema do banco Supabase |

## Stack

- **Frontend:** HTML/CSS/JS puro — zero dependências, carrega instantâneo
- **Backend:** Supabase (PostgreSQL + Auth + RLS)
- **Deploy:** Vercel (CI/CD automático via GitHub)
- **Fonte:** Plus Jakarta Sans (Google Fonts)

## Setup em 5 passos

### 1. Supabase
1. Crie um projeto em supabase.com
2. Vá em SQL Editor e execute o conteúdo de `schema.sql`
3. Copie a **URL** e a **anon key** (Settings → API)

### 2. Configurar o index.html
Abra `index.html` e substitua:
```js
const SUPABASE_URL = 'COLE_SUPABASE_URL_AQUI';
const SUPABASE_KEY = 'COLE_SUPABASE_ANON_KEY_AQUI';
```

### 3. Deploy no Vercel
1. Suba os arquivos no GitHub
2. Conecte o repositório no Vercel
3. Deploy automático em ~30 segundos

### 4. Testar
Acesse a URL do Vercel → clique em "Entrar com conta demo"

## Módulos implementados

- ✅ Dashboard com KPIs em tempo real
- ✅ Agenda com calendário visual e slots por dia
- ✅ Agendamentos (CRUD completo + filtros + paginação)
- ✅ Clientes (CRUD + histórico de atendimentos)
- ✅ Serviços (CRUD + categorias + duração + comissão)
- ✅ Profissionais (CRUD + cor + comissão + ranking)
- ✅ Financeiro (filtro por período + exportação CSV)
- ✅ Relatórios (top serviços, top profissionais, por dia, por mês)
- ✅ Perfil público (configuração do link de agendamento)
- ✅ Configurações (horários de funcionamento + mensagens)
- ✅ Planos (Free / Pro R$79 / Premium R$159)
- ✅ Login / Cadastro / Demo
- ✅ Seed de dados demo (5 clientes, 6 serviços, 2 profissionais, 5 agendamentos)
- ✅ PWA instalável
- ✅ Responsivo mobile

## Planos

| Plano | Preço | Profissionais | Agendamentos | Link público |
|-------|-------|---------------|--------------|--------------|
| Free  | R$ 0  | 1 | 50/mês | ❌ |
| Pro   | R$ 79/mês | 3 | Ilimitado | ✅ |
| Premium | R$ 159/mês | Ilimitado | Ilimitado | ✅ |

## MRR potencial

```
100 clientes Pro × R$79    = R$ 7.900/mês
 50 clientes Premium × R$159 = R$ 7.950/mês
Total estimado (150 clientes) = R$ 15.850 MRR
```

## Mercado

- 500.000+ salões de beleza no Brasil
- 300.000+ barbearias
- 200.000+ clínicas de estética
- **Total endereçável:** ~1 milhão de estabelecimentos

## Próximos passos

- [ ] Integração WhatsApp (Evolution API / Z-API)
- [ ] Link de agendamento público (página do cliente)
- [ ] Notificações push (PWA)
- [ ] Integração Google Calendar
- [ ] Módulo de comanda / caixa
- [ ] App mobile nativo (Capacitor)
- [ ] Multi-unidade
