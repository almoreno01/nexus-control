-- NEXUS Versión 1 - Supabase schema
-- Ejecutar en Supabase > SQL Editor.

create table if not exists public.nexus_meta (
  id text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_at_client bigint not null default 0
);

create table if not exists public.nexus_records (
  cloud_doc text not null,
  record_id text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_at_client bigint not null default 0,
  deleted boolean not null default false,
  primary key (cloud_doc, record_id)
);

create index if not exists nexus_records_cloud_doc_idx
  on public.nexus_records (cloud_doc);

create index if not exists nexus_records_cloud_doc_updated_idx
  on public.nexus_records (cloud_doc, updated_at_client desc);

create table if not exists public.nexus_audit (
  cloud_doc text not null,
  op_id text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  primary key (cloud_doc, op_id)
);

create index if not exists nexus_audit_cloud_doc_created_idx
  on public.nexus_audit (cloud_doc, created_at desc);

alter table public.nexus_meta enable row level security;
alter table public.nexus_records enable row level security;
alter table public.nexus_audit enable row level security;

drop policy if exists "nexus_meta_read" on public.nexus_meta;
drop policy if exists "nexus_meta_insert" on public.nexus_meta;
drop policy if exists "nexus_meta_update" on public.nexus_meta;
drop policy if exists "nexus_meta_delete" on public.nexus_meta;

drop policy if exists "nexus_records_read" on public.nexus_records;
drop policy if exists "nexus_records_insert" on public.nexus_records;
drop policy if exists "nexus_records_update" on public.nexus_records;
drop policy if exists "nexus_records_delete" on public.nexus_records;

drop policy if exists "nexus_audit_read" on public.nexus_audit;
drop policy if exists "nexus_audit_insert" on public.nexus_audit;
drop policy if exists "nexus_audit_update" on public.nexus_audit;
drop policy if exists "nexus_audit_delete" on public.nexus_audit;

-- Políticas abiertas para poder usar la app sin login Supabase.
-- Para producción real, conviene cerrar esto con Supabase Auth.
create policy "nexus_meta_read" on public.nexus_meta
  for select using (true);
create policy "nexus_meta_insert" on public.nexus_meta
  for insert with check (true);
create policy "nexus_meta_update" on public.nexus_meta
  for update using (true) with check (true);
create policy "nexus_meta_delete" on public.nexus_meta
  for delete using (true);

create policy "nexus_records_read" on public.nexus_records
  for select using (true);
create policy "nexus_records_insert" on public.nexus_records
  for insert with check (true);
create policy "nexus_records_update" on public.nexus_records
  for update using (true) with check (true);
create policy "nexus_records_delete" on public.nexus_records
  for delete using (true);

create policy "nexus_audit_read" on public.nexus_audit
  for select using (true);
create policy "nexus_audit_insert" on public.nexus_audit
  for insert with check (true);
create policy "nexus_audit_update" on public.nexus_audit
  for update using (true) with check (true);
create policy "nexus_audit_delete" on public.nexus_audit
  for delete using (true);
