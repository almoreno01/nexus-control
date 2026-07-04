-- NEXUS - REINICIO TOTAL DE SUPABASE
-- ADVERTENCIA: borra las tablas NEXUS actuales y sus datos.

drop table if exists public.nexus_audit cascade;
drop table if exists public.nexus_records cascade;
drop table if exists public.nexus_meta cascade;

create table public.nexus_meta (
  id text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_at_client bigint not null default 0
);

create table public.nexus_records (
  cloud_doc text not null,
  record_id text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_at_client bigint not null default 0,
  deleted boolean not null default false,
  primary key (cloud_doc, record_id)
);

create index nexus_records_cloud_doc_idx
on public.nexus_records (cloud_doc);

create index nexus_records_cloud_doc_updated_idx
on public.nexus_records (cloud_doc, updated_at_client desc);

create table public.nexus_audit (
  cloud_doc text not null,
  op_id text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  primary key (cloud_doc, op_id)
);

create index nexus_audit_cloud_doc_created_idx
on public.nexus_audit (cloud_doc, created_at desc);

grant usage on schema public to anon;
grant select, insert, update, delete on table public.nexus_meta to anon;
grant select, insert, update, delete on table public.nexus_records to anon;
grant select, insert, update, delete on table public.nexus_audit to anon;

grant usage on schema public to authenticated;
grant select, insert, update, delete on table public.nexus_meta to authenticated;
grant select, insert, update, delete on table public.nexus_records to authenticated;
grant select, insert, update, delete on table public.nexus_audit to authenticated;

alter table public.nexus_meta enable row level security;
alter table public.nexus_records enable row level security;
alter table public.nexus_audit enable row level security;

create policy "nexus_meta_select" on public.nexus_meta
for select to anon using (true);
create policy "nexus_meta_insert" on public.nexus_meta
for insert to anon with check (true);
create policy "nexus_meta_update" on public.nexus_meta
for update to anon using (true) with check (true);
create policy "nexus_meta_delete" on public.nexus_meta
for delete to anon using (true);

create policy "nexus_records_select" on public.nexus_records
for select to anon using (true);
create policy "nexus_records_insert" on public.nexus_records
for insert to anon with check (true);
create policy "nexus_records_update" on public.nexus_records
for update to anon using (true) with check (true);
create policy "nexus_records_delete" on public.nexus_records
for delete to anon using (true);

create policy "nexus_audit_select" on public.nexus_audit
for select to anon using (true);
create policy "nexus_audit_insert" on public.nexus_audit
for insert to anon with check (true);
create policy "nexus_audit_update" on public.nexus_audit
for update to anon using (true) with check (true);
create policy "nexus_audit_delete" on public.nexus_audit
for delete to anon using (true);

select
  to_regclass('public.nexus_meta') as nexus_meta,
  to_regclass('public.nexus_records') as nexus_records,
  to_regclass('public.nexus_audit') as nexus_audit;
