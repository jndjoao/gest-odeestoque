-- Grupo J Auto App: criação do banco de dados
-- Cole este arquivo inteiro no SQL Editor do Supabase e clique em Run.
-- Pode ser executado mais de uma vez sem causar erro.

create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  telefone text,
  email text,
  cidade text,
  obs text,
  created_at timestamptz default now()
);

create table if not exists produtos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references clientes(id) on delete cascade,
  nome text not null,
  valor numeric,
  obs text,
  status text not null default 'disponivel',
  created_at timestamptz default now()
);

-- Segurança: só usuários com login acessam os dados
alter table clientes enable row level security;
alter table produtos enable row level security;

drop policy if exists "usuarios logados clientes" on clientes;
drop policy if exists "usuarios logados produtos" on produtos;

create policy "usuarios logados clientes" on clientes
  for all to authenticated using (true) with check (true);
create policy "usuarios logados produtos" on produtos
  for all to authenticated using (true) with check (true);

-- Registra automaticamente qual usuário (e-mail do login) criou cada cadastro
alter table clientes add column if not exists criado_por text default (auth.jwt() ->> 'email');
alter table produtos add column if not exists criado_por text default (auth.jwt() ->> 'email');
