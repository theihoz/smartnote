create table if not exists public.notes (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null default '',
  kind text not null check (kind in ('text', 'checklist')),
  is_favorite boolean not null default false,
  color_key text not null default 'lavender',
  tags jsonb not null default '[]'::jsonb,
  image_paths jsonb not null default '[]'::jsonb,
  checklist jsonb not null default '[]'::jsonb,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

alter table public.notes enable row level security;

create policy "users read their own notes"
on public.notes for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "users insert their own notes"
on public.notes for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "users update their own notes"
on public.notes for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "users delete their own notes"
on public.notes for delete
to authenticated
using ((select auth.uid()) = user_id);

create index if not exists notes_user_updated_idx
on public.notes (user_id, updated_at desc);
