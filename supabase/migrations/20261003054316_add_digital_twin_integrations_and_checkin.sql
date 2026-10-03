
create table public.map_nodes (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  code text not null,
  label text not null,
  node_type text not null,
  status text not null default 'active',
  guest_visible boolean not null default true,
  x_percent numeric(6,3) check (x_percent is null or (x_percent >= 0 and x_percent <= 100)),
  y_percent numeric(6,3) check (y_percent is null or (y_percent >= 0 and y_percent <= 100)),
  description text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(property_id, code)
);

create table public.map_edges (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  from_node_id uuid not null references public.map_nodes(id) on delete cascade,
  to_node_id uuid not null references public.map_nodes(id) on delete cascade,
  route_type text not null default 'walk',
  distance_m numeric(10,2),
  estimated_minutes numeric(10,2),
  accessible boolean not null default true,
  bidirectional boolean not null default true,
  geometry jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  provider text not null,
  category text not null,
  connection_mode text not null default 'adapter',
  status text not null default 'not_configured',
  external_account_ref text,
  capabilities jsonb not null default '[]'::jsonb,
  config_public jsonb not null default '{}'::jsonb,
  last_sync_at timestamptz,
  last_success_at timestamptz,
  last_error text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(organisation_id, property_id, provider)
);

create table public.sync_runs (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  integration_connection_id uuid references public.integration_connections(id) on delete set null,
  sync_type text not null,
  status text not null default 'started',
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  records_received integer not null default 0,
  records_created integer not null default 0,
  records_updated integer not null default 0,
  records_failed integer not null default 0,
  error_summary text,
  metadata jsonb not null default '{}'::jsonb
);

create table public.checkin_sessions (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  guest_id uuid references public.guests(id) on delete set null,
  channel text not null default 'kiosk',
  status text not null default 'started',
  booking_lookup_method text,
  vehicle_plate_captured boolean not null default false,
  payment_required boolean not null default false,
  payment_completed boolean not null default false,
  credentials_issued boolean not null default false,
  map_presented boolean not null default false,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create table public.guest_messages (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  guest_id uuid references public.guests(id) on delete set null,
  channel text not null,
  direction text not null default 'outbound',
  template_key text,
  subject text,
  body text,
  status text not null default 'queued',
  provider_message_id text,
  sent_at timestamptz,
  delivered_at timestamptz,
  failed_at timestamptz,
  failure_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.external_principals (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  provider text not null,
  external_user_id text not null,
  email text,
  role text not null default 'member',
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(provider, external_user_id, organisation_id)
);

create index map_nodes_property_type_idx on public.map_nodes(property_id, node_type);
create index map_edges_property_idx on public.map_edges(property_id);
create index integration_connections_property_idx on public.integration_connections(property_id, status);
create index sync_runs_connection_time_idx on public.sync_runs(integration_connection_id, started_at desc);
create index checkin_sessions_property_time_idx on public.checkin_sessions(property_id, started_at desc);
create index guest_messages_reservation_time_idx on public.guest_messages(reservation_id, created_at desc);
create index external_principals_org_idx on public.external_principals(organisation_id, active);

create trigger map_nodes_touch_updated_at before update on public.map_nodes
for each row execute function public.touch_updated_at();

create trigger integration_connections_touch_updated_at before update on public.integration_connections
for each row execute function public.touch_updated_at();

create trigger external_principals_touch_updated_at before update on public.external_principals
for each row execute function public.touch_updated_at();

alter table public.map_nodes enable row level security;
alter table public.map_edges enable row level security;
alter table public.integration_connections enable row level security;
alter table public.sync_runs enable row level security;
alter table public.checkin_sessions enable row level security;
alter table public.guest_messages enable row level security;
alter table public.external_principals enable row level security;

create policy map_nodes_org_member_access on public.map_nodes
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy map_edges_org_member_access on public.map_edges
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy integration_connections_org_member_access on public.integration_connections
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy sync_runs_org_member_access on public.sync_runs
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy checkin_sessions_org_member_access on public.checkin_sessions
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy guest_messages_org_member_access on public.guest_messages
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy external_principals_org_member_access on public.external_principals
for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));
