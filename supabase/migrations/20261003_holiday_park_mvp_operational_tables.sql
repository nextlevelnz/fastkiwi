create table if not exists public.facility_bookings (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  facility_id uuid not null references public.facilities(id) on delete cascade,
  guest_id uuid references public.guests(id) on delete set null,
  payment_id uuid references public.payments(id) on delete set null,
  credential_id uuid references public.access_credentials(id) on delete set null,
  status text not null default 'reserved',
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  amount numeric(14,2) not null default 0,
  currency text not null default 'NZD',
  access_window_before_minutes integer not null default 10,
  access_window_after_minutes integer not null default 10,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table if not exists public.lockbox_assignments (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  accommodation_unit_id uuid references public.accommodation_units(id) on delete set null,
  device_id uuid references public.devices(id) on delete set null,
  credential_id uuid references public.access_credentials(id) on delete set null,
  lockbox_code text not null,
  status text not null default 'assigned',
  valid_from timestamptz not null,
  valid_until timestamptz not null,
  key_collected_at timestamptz,
  key_returned_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (valid_until > valid_from)
);

create table if not exists public.gate_authorisations (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid not null references public.reservations(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  direction text not null default 'both',
  status text not null default 'active',
  valid_from timestamptz not null,
  valid_until timestamptz not null,
  provider text,
  provider_ref text,
  last_entry_at timestamptz,
  last_exit_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (valid_until > valid_from)
);

create table if not exists public.utility_allocations (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references public.organisations(id) on delete cascade,
  property_id uuid not null references public.properties(id) on delete cascade,
  reservation_id uuid references public.reservations(id) on delete set null,
  accommodation_unit_id uuid references public.accommodation_units(id) on delete set null,
  device_id uuid not null references public.devices(id) on delete cascade,
  utility_type text not null default 'electricity',
  status text not null default 'active',
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  start_reading numeric(18,6),
  end_reading numeric(18,6),
  usage_quantity numeric(18,6),
  usage_unit text not null default 'kWh',
  unit_rate numeric(14,4),
  amount numeric(14,2),
  currency text not null default 'NZD',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists facility_bookings_reservation_idx on public.facility_bookings(reservation_id, starts_at);
create index if not exists facility_bookings_facility_time_idx on public.facility_bookings(facility_id, starts_at, ends_at);
create index if not exists lockbox_assignments_reservation_idx on public.lockbox_assignments(reservation_id);
create index if not exists gate_authorisations_vehicle_idx on public.gate_authorisations(vehicle_id, valid_from, valid_until);
create index if not exists utility_allocations_unit_idx on public.utility_allocations(accommodation_unit_id, starts_at);

create trigger facility_bookings_touch_updated_at before update on public.facility_bookings for each row execute function public.touch_updated_at();
create trigger lockbox_assignments_touch_updated_at before update on public.lockbox_assignments for each row execute function public.touch_updated_at();
create trigger gate_authorisations_touch_updated_at before update on public.gate_authorisations for each row execute function public.touch_updated_at();
create trigger utility_allocations_touch_updated_at before update on public.utility_allocations for each row execute function public.touch_updated_at();

alter table public.facility_bookings enable row level security;
alter table public.lockbox_assignments enable row level security;
alter table public.gate_authorisations enable row level security;
alter table public.utility_allocations enable row level security;

create policy facility_bookings_org_member_access on public.facility_bookings
for all using (private.user_has_org(organisation_id)) with check (private.user_has_org(organisation_id));
create policy lockbox_assignments_org_member_access on public.lockbox_assignments
for all using (private.user_has_org(organisation_id)) with check (private.user_has_org(organisation_id));
create policy gate_authorisations_org_member_access on public.gate_authorisations
for all using (private.user_has_org(organisation_id)) with check (private.user_has_org(organisation_id));
create policy utility_allocations_org_member_access on public.utility_allocations
for all using (private.user_has_org(organisation_id)) with check (private.user_has_org(organisation_id));
