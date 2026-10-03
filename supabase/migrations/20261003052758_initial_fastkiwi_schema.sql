
create extension if not exists pgcrypto;

create table public.organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  status text not null default 'active',
  timezone text not null default 'Pacific/Auckland',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organisation_members (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (organisation_id, user_id)
);

create table public.properties (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  name text not null,
  slug text not null,
  status text not null default 'active',
  timezone text not null default 'Pacific/Auckland',
  address jsonb not null default '{}'::jsonb,
  geo jsonb not null default '{}'::jsonb,
  external_refs jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organisation_id, slug)
);

create table public.property_members (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (property_id, user_id)
);

create or replace function public.user_has_org(_organisation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.organisation_members m
    where m.organisation_id = _organisation_id
      and m.user_id = auth.uid()
      and m.active = true
  );
$$;

create or replace function public.user_has_property(_property_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.property_members pm
    where pm.property_id = _property_id
      and pm.user_id = auth.uid()
      and pm.active = true
  )
  or exists (
    select 1
    from public.properties p
    where p.id = _property_id
      and public.user_has_org(p.organisation_id)
  );
$$;

create table public.accommodation_units (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  code text not null,
  name text not null,
  unit_type text not null,
  capacity integer not null default 1 check (capacity > 0),
  status text not null default 'active',
  map_node_id text,
  external_refs jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, code)
);

create table public.rate_plans (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  name text not null,
  currency text not null default 'NZD',
  active boolean not null default true,
  rules jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, name)
);

create table public.guests (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  first_name text,
  last_name text,
  email text,
  phone text,
  external_refs jsonb not null default '{}'::jsonb,
  preferences jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reservations (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  accommodation_unit_id uuid references public.accommodation_units(id) on delete set null,
  primary_guest_id uuid references public.guests(id) on delete set null,
  rate_plan_id uuid references public.rate_plans(id) on delete set null,
  status text not null default 'pending',
  source text not null default 'direct',
  external_id text,
  confirmation_code text,
  check_in timestamptz,
  check_out timestamptz,
  adults integer not null default 1 check (adults >= 0),
  children integer not null default 0 check (children >= 0),
  currency text not null default 'NZD',
  total_amount numeric(14,2) not null default 0,
  balance_due numeric(14,2) not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index reservations_external_unique
  on public.reservations(property_id, source, external_id)
  where external_id is not null;

create table public.reservation_guests (
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  guest_id uuid not null references public.guests(id) on delete cascade,
  guest_role text not null default 'guest',
  created_at timestamptz not null default now(),
  primary key (reservation_id, guest_id)
);

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  plate text not null,
  normalized_plate text not null,
  country_code text default 'NZ',
  vehicle_type text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (organisation_id, normalized_plate)
);

create table public.reservation_vehicles (
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  valid_from timestamptz,
  valid_until timestamptz,
  created_at timestamptz not null default now(),
  primary key (reservation_id, vehicle_id)
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  provider text not null,
  provider_payment_id text,
  status text not null default 'pending',
  amount numeric(14,2) not null default 0,
  currency text not null default 'NZD',
  payment_type text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.facilities (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  code text not null,
  name text not null,
  facility_type text not null,
  access_mode text not null default 'included',
  price numeric(14,2) not null default 0,
  currency text not null default 'NZD',
  capacity integer,
  map_node_id text,
  status text not null default 'active',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, code)
);

create table public.access_credentials (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete cascade,
  guest_id uuid references public.guests(id) on delete set null,
  credential_type text not null,
  provider text,
  provider_credential_id text,
  secret_hash text,
  status text not null default 'active',
  valid_from timestamptz,
  valid_until timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.facility_entitlements (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  facility_id uuid not null references public.facilities(id) on delete cascade,
  entitlement_type text not null default 'included',
  status text not null default 'active',
  valid_from timestamptz,
  valid_until timestamptz,
  usage_limit integer,
  usage_count integer not null default 0,
  price numeric(14,2) not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (reservation_id, facility_id, entitlement_type)
);

create table public.access_events (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  credential_id uuid references public.access_credentials(id) on delete set null,
  facility_id uuid references public.facilities(id) on delete set null,
  device_id uuid,
  event_type text not null,
  decision text,
  reason text,
  source text,
  metadata jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create table public.devices (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  code text not null,
  name text not null,
  device_type text not null,
  provider text,
  provider_device_id text,
  status text not null default 'unknown',
  desired_state jsonb not null default '{}'::jsonb,
  last_seen_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (property_id, code)
);

alter table public.access_events
  add constraint access_events_device_fk
  foreign key (device_id) references public.devices(id) on delete set null;

create table public.device_states (
  device_id uuid primary key references public.devices(id) on delete cascade,
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  actual_state jsonb not null default '{}'::jsonb,
  observed_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.device_commands (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  device_id uuid not null references public.devices(id) on delete cascade,
  command_type text not null,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'queued',
  idempotency_key text,
  requested_by uuid references auth.users(id) on delete set null,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  result jsonb not null default '{}'::jsonb
);
create unique index device_commands_idempotency_unique
  on public.device_commands(organisation_id, idempotency_key)
  where idempotency_key is not null;

create table public.device_events (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  device_id uuid not null references public.devices(id) on delete cascade,
  event_type text not null,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  task_type text not null,
  title text not null,
  description text,
  status text not null default 'open',
  priority text not null default 'normal',
  assigned_to uuid references auth.users(id) on delete set null,
  due_at timestamptz,
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.work_orders (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  device_id uuid references public.devices(id) on delete set null,
  facility_id uuid references public.facilities(id) on delete set null,
  title text not null,
  description text,
  status text not null default 'open',
  priority text not null default 'normal',
  assigned_to uuid references auth.users(id) on delete set null,
  due_at timestamptz,
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  sku text,
  name text not null,
  category text,
  unit_price numeric(14,2) not null default 0,
  currency text not null default 'NZD',
  stock_on_hand numeric(14,3) not null default 0,
  reorder_level numeric(14,3),
  active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index inventory_sku_unique
  on public.inventory_items(property_id, sku)
  where sku is not null;

create table public.sales (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  guest_id uuid references public.guests(id) on delete set null,
  channel text,
  status text not null default 'completed',
  subtotal numeric(14,2) not null default 0,
  tax_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0,
  currency text not null default 'NZD',
  payment_id uuid references public.payments(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  inventory_item_id uuid references public.inventory_items(id) on delete set null,
  description text not null,
  quantity numeric(14,3) not null default 1,
  unit_price numeric(14,2) not null default 0,
  line_total numeric(14,2) not null default 0,
  metadata jsonb not null default '{}'::jsonb
);

create table public.meter_readings (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  device_id uuid references public.devices(id) on delete set null,
  reservation_id uuid references public.reservations(id) on delete set null,
  meter_type text not null,
  value numeric(18,6) not null,
  unit text not null,
  recorded_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create table public.charging_sessions (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  device_id uuid references public.devices(id) on delete set null,
  reservation_id uuid references public.reservations(id) on delete set null,
  guest_id uuid references public.guests(id) on delete set null,
  provider_session_id text,
  status text not null default 'active',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  energy_kwh numeric(14,3),
  amount numeric(14,2),
  currency text not null default 'NZD',
  metadata jsonb not null default '{}'::jsonb
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  name text not null,
  supplier_type text,
  website text,
  email text,
  phone text,
  regions text[] not null default '{}',
  status text not null default 'prospect',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  supplier_id uuid references public.suppliers(id) on delete set null,
  name text not null,
  model text,
  product_type text not null,
  price_from numeric(14,2),
  currency text not null default 'NZD',
  lead_time_days integer,
  rental_capable boolean not null default false,
  show_home_eligible boolean not null default false,
  specs jsonb not null default '{}'::jsonb,
  media jsonb not null default '[]'::jsonb,
  source_type text not null default 'supplier',
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.quotes (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete set null,
  supplier_id uuid references public.suppliers(id) on delete set null,
  title text not null,
  status text not null default 'draft',
  currency text not null default 'NZD',
  subtotal numeric(14,2) not null default 0,
  tax_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0,
  assumptions jsonb not null default '{}'::jsonb,
  valid_until date,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.quote_items (
  id uuid primary key default gen_random_uuid(),
  quote_id uuid not null references public.quotes(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  description text not null,
  quantity numeric(14,3) not null default 1,
  unit_price numeric(14,2) not null default 0,
  line_total numeric(14,2) not null default 0,
  source_type text not null default 'estimate',
  metadata jsonb not null default '{}'::jsonb
);

create table public.leads (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete set null,
  lead_type text not null default 'property',
  name text not null,
  company text,
  email text,
  phone text,
  status text not null default 'new',
  source text,
  source_url text,
  confidence numeric(5,2),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.automation_events (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  event_type text not null,
  aggregate_type text,
  aggregate_id uuid,
  payload jsonb not null default '{}'::jsonb,
  idempotency_key text,
  correlation_id uuid,
  causation_id uuid,
  processing_status text not null default 'pending',
  occurred_at timestamptz not null default now(),
  processed_at timestamptz
);
create unique index automation_events_idempotency_unique
  on public.automation_events(organisation_id, idempotency_key)
  where idempotency_key is not null;

create table public.automation_jobs (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  event_id uuid references public.automation_events(id) on delete set null,
  job_type text not null,
  status text not null default 'queued',
  payload jsonb not null default '{}'::jsonb,
  attempts integer not null default 0,
  max_attempts integer not null default 5,
  run_after timestamptz not null default now(),
  locked_at timestamptz,
  completed_at timestamptz,
  last_error text,
  created_at timestamptz not null default now()
);

create table public.webhook_deliveries (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  provider text not null,
  external_event_id text,
  direction text not null default 'inbound',
  status text not null default 'received',
  headers jsonb not null default '{}'::jsonb,
  payload jsonb not null default '{}'::jsonb,
  attempts integer not null default 0,
  last_error text,
  received_at timestamptz not null default now(),
  processed_at timestamptz
);
create unique index webhook_external_event_unique
  on public.webhook_deliveries(provider, external_event_id)
  where external_event_id is not null;

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid references public.organisations(id) on delete cascade,
  property_id uuid references public.properties(id) on delete cascade,
  actor_user_id uuid references auth.users(id) on delete set null,
  actor_type text not null default 'user',
  action text not null,
  target_type text,
  target_id uuid,
  before_data jsonb,
  after_data jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index properties_org_idx on public.properties(organisation_id);
create index units_property_idx on public.accommodation_units(property_id);
create index reservations_property_dates_idx on public.reservations(property_id, check_in, check_out);
create index reservations_guest_idx on public.reservations(primary_guest_id);
create index payments_reservation_idx on public.payments(reservation_id);
create index entitlements_reservation_idx on public.facility_entitlements(reservation_id);
create index access_events_property_time_idx on public.access_events(property_id, occurred_at desc);
create index device_events_device_time_idx on public.device_events(device_id, occurred_at desc);
create index tasks_property_status_idx on public.tasks(property_id, status);
create index meter_readings_device_time_idx on public.meter_readings(device_id, recorded_at desc);
create index automation_events_status_time_idx on public.automation_events(processing_status, occurred_at);
create index automation_jobs_status_run_idx on public.automation_jobs(status, run_after);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array[
    'organisations','properties','accommodation_units','rate_plans','guests','reservations',
    'payments','facilities','devices','device_states','tasks','work_orders','inventory_items',
    'suppliers','products','quotes','leads'
  ]
  loop
    execute format('create trigger %I_touch_updated_at before update on public.%I for each row execute function public.touch_updated_at()', t, t);
  end loop;
end $$;

alter table public.organisations enable row level security;
alter table public.organisation_members enable row level security;
alter table public.properties enable row level security;
alter table public.property_members enable row level security;
alter table public.accommodation_units enable row level security;
alter table public.rate_plans enable row level security;
alter table public.guests enable row level security;
alter table public.reservations enable row level security;
alter table public.reservation_guests enable row level security;
alter table public.vehicles enable row level security;
alter table public.reservation_vehicles enable row level security;
alter table public.payments enable row level security;
alter table public.facilities enable row level security;
alter table public.access_credentials enable row level security;
alter table public.facility_entitlements enable row level security;
alter table public.access_events enable row level security;
alter table public.devices enable row level security;
alter table public.device_states enable row level security;
alter table public.device_commands enable row level security;
alter table public.device_events enable row level security;
alter table public.tasks enable row level security;
alter table public.work_orders enable row level security;
alter table public.inventory_items enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.meter_readings enable row level security;
alter table public.charging_sessions enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.quotes enable row level security;
alter table public.quote_items enable row level security;
alter table public.leads enable row level security;
alter table public.automation_events enable row level security;
alter table public.automation_jobs enable row level security;
alter table public.webhook_deliveries enable row level security;
alter table public.audit_logs enable row level security;

create policy organisations_member_access on public.organisations
  for all using (public.user_has_org(id)) with check (public.user_has_org(id));

create policy organisation_members_self_read on public.organisation_members
  for select using (user_id = auth.uid());

create policy properties_member_access on public.properties
  for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id));

create policy property_members_member_read on public.property_members
  for select using (user_id = auth.uid() or public.user_has_property(property_id));

do $$
declare
  t text;
begin
  foreach t in array array[
    'accommodation_units','rate_plans','guests','reservations','vehicles','payments','facilities',
    'access_credentials','facility_entitlements','access_events','devices','device_states',
    'device_commands','device_events','tasks','work_orders','inventory_items','sales',
    'meter_readings','charging_sessions','suppliers','products','quotes','leads',
    'automation_events','automation_jobs','webhook_deliveries','audit_logs'
  ]
  loop
    execute format(
      'create policy %I_org_member_access on public.%I for all using (public.user_has_org(organisation_id)) with check (public.user_has_org(organisation_id))',
      t, t
    );
  end loop;
end $$;

create policy reservation_guests_member_access on public.reservation_guests
  for all using (
    exists (
      select 1 from public.reservations r
      where r.id = reservation_id and public.user_has_org(r.organisation_id)
    )
  ) with check (
    exists (
      select 1 from public.reservations r
      where r.id = reservation_id and public.user_has_org(r.organisation_id)
    )
  );

create policy reservation_vehicles_member_access on public.reservation_vehicles
  for all using (
    exists (
      select 1 from public.reservations r
      where r.id = reservation_id and public.user_has_org(r.organisation_id)
    )
  ) with check (
    exists (
      select 1 from public.reservations r
      where r.id = reservation_id and public.user_has_org(r.organisation_id)
    )
  );

create policy sale_items_member_access on public.sale_items
  for all using (
    exists (
      select 1 from public.sales s
      where s.id = sale_id and public.user_has_org(s.organisation_id)
    )
  ) with check (
    exists (
      select 1 from public.sales s
      where s.id = sale_id and public.user_has_org(s.organisation_id)
    )
  );

create policy quote_items_member_access on public.quote_items
  for all using (
    exists (
      select 1 from public.quotes q
      where q.id = quote_id and public.user_has_org(q.organisation_id)
    )
  ) with check (
    exists (
      select 1 from public.quotes q
      where q.id = quote_id and public.user_has_org(q.organisation_id)
    )
  );
