-- APP_DATA_MODEL_SQL_DRAFT.sql
-- Date: 2026-06-26
-- Purpose: Supabase/Postgres draft schema for the MVP runtime data model.
-- Source docs:
--   - DATA_SCHEMA_ZH.md
--   - ONBOARDING_FLOW_ZH.md
--
-- This is a draft, not a final production migration.
-- It intentionally excludes later tables such as user_uploaded_files,
-- rag_retrieval_runs, applications, parent workspaces, and institution admin.

begin;

-- ---------------------------------------------------------------------------
-- 0. Extensions
-- ---------------------------------------------------------------------------

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- 1. Enums
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (
    select 1 from pg_type
    where typname = 'account_type'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.account_type as enum ('student', 'demo', 'admin');
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'record_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.record_status as enum ('active', 'archived', 'deleted');
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'student_type'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.student_type as enum (
      'high_school_student',
      'university_student',
      'recent_graduate',
      'early_career',
      'other',
      'unknown'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'student_stage'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.student_stage as enum (
      'high_school_explorer',
      'university_beginner',
      'university_mid',
      'university_job_search',
      'recent_graduate',
      'early_career',
      'explorer_unknown'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'path_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.path_status as enum ('exploring', 'primary', 'archived');
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'roadmap_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.roadmap_status as enum (
      'draft',
      'active',
      'completed',
      'paused',
      'archived'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'task_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.task_status as enum (
      'not_started',
      'in_progress',
      'done',
      'blocked',
      'need_help',
      'skipped'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'project_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.project_status as enum (
      'not_started',
      'in_progress',
      'completed',
      'paused',
      'archived'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'match_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.match_status as enum ('completed', 'partial', 'failed');
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'profile_event_type'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.profile_event_type as enum (
      'created',
      'updated',
      'summary_generated',
      'field_confirmed'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'profile_event_source'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.profile_event_source as enum (
      'onboarding',
      'user_edit',
      'advisor_prompt',
      'admin'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'project_review_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.project_review_status as enum (
      'not_reviewed',
      'ai_reviewed',
      'user_revised'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'advisor_session_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.advisor_session_status as enum (
      'active',
      'closed',
      'archived'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'advisor_message_role'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.advisor_message_role as enum (
      'system',
      'user',
      'assistant',
      'tool'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'risk_level'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.risk_level as enum ('low', 'medium', 'high', 'blocked');
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'consent_type'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.consent_type as enum (
      'terms_of_service',
      'privacy_policy',
      'profile_personalization',
      'ai_advisor',
      'user_uploaded_files',
      'marketing_communications',
      'guardian_or_parental_consent'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'consent_source'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.consent_source as enum (
      'signup',
      'onboarding',
      'advisor',
      'settings'
    );
  end if;

  if not exists (
    select 1 from pg_type
    where typname = 'actor_type'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.actor_type as enum ('user', 'system', 'admin');
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Utility functions
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Supabase helper: maps auth.uid() to the product-level user_accounts.id.
-- Demo users without auth_user_id should be created and read by trusted server code
-- with the service role, not by direct anonymous RLS policies.
create or replace function public.current_app_user_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select ua.id
  from public.user_accounts ua
  where ua.auth_user_id = auth.uid()
  limit 1
$$;

grant execute on function public.current_app_user_id() to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Core tables
-- ---------------------------------------------------------------------------

create table if not exists public.user_accounts (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete set null,
  email text,
  display_name text,
  locale text not null default 'en-CA',
  country text not null default 'Canada',
  timezone text,
  account_type public.account_type not null default 'student',
  status public.record_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_accounts_country_not_blank check (length(trim(country)) > 0),
  constraint user_accounts_locale_not_blank check (length(trim(locale)) > 0)
);

create table if not exists public.consent_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  consent_type public.consent_type not null,
  policy_version text not null,
  accepted boolean not null,
  accepted_at timestamptz,
  withdrawn_at timestamptz,
  source public.consent_source,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint consent_records_policy_version_not_blank
    check (length(trim(policy_version)) > 0),
  constraint consent_records_withdrawn_after_accept
    check (withdrawn_at is null or accepted_at is not null)
);

create table if not exists public.student_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  profile_version integer not null default 1,
  completed_profile boolean not null default false,
  student_type public.student_type not null default 'unknown',
  student_stage public.student_stage not null default 'explorer_unknown',
  age_band text,
  country text not null default 'Canada',
  province text,
  school text,
  grade_level text,
  major text,
  target_majors jsonb not null default '[]'::jsonb,
  liked_subjects jsonb not null default '[]'::jsonb,
  disliked_subjects jsonb not null default '[]'::jsonb,
  interested_industries jsonb not null default '[]'::jsonb,
  preferred_work_styles jsonb not null default '[]'::jsonb,
  skills jsonb not null default '{}'::jsonb,
  projects jsonb not null default '[]'::jsonb,
  internships jsonb not null default '[]'::jsonb,
  extracurriculars jsonb not null default '[]'::jsonb,
  short_term_goal text,
  long_term_goal text,
  main_question text not null default '',
  weekly_time_commitment_hours numeric(5,2),
  profile_summary text,
  profile_summary_version text,
  data_quality_flags jsonb not null default '{}'::jsonb,
  status public.record_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint student_profiles_id_user_id_key unique (id, user_id),
  constraint student_profiles_profile_version_positive check (profile_version > 0),
  constraint student_profiles_country_not_blank check (length(trim(country)) > 0),
  constraint student_profiles_weekly_time_reasonable check (
    weekly_time_commitment_hours is null
    or (weekly_time_commitment_hours >= 0 and weekly_time_commitment_hours <= 80)
  ),
  constraint student_profiles_completed_has_main_question check (
    completed_profile = false
    or length(trim(main_question)) > 0
  )
);

create table if not exists public.profile_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  student_profile_id uuid not null,
  event_type public.profile_event_type not null,
  changed_fields jsonb not null default '[]'::jsonb,
  before_snapshot_redacted jsonb,
  after_snapshot_redacted jsonb,
  source public.profile_event_source not null,
  created_at timestamptz not null default now(),
  constraint profile_events_profile_user_fk
    foreign key (student_profile_id, user_id)
    references public.student_profiles(id, user_id)
    on delete cascade
);

create table if not exists public.career_matches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  student_profile_id uuid not null,
  profile_version integer not null,
  matcher_version text not null,
  kb_version text,
  input_snapshot jsonb not null default '{}'::jsonb,
  candidate_path_ids jsonb not null default '[]'::jsonb,
  status public.match_status not null default 'completed',
  uncertainty jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint career_matches_id_user_id_key unique (id, user_id),
  constraint career_matches_profile_user_fk
    foreign key (student_profile_id, user_id)
    references public.student_profiles(id, user_id)
    on delete cascade,
  constraint career_matches_profile_version_positive check (profile_version > 0),
  constraint career_matches_matcher_version_not_blank
    check (length(trim(matcher_version)) > 0)
);

create table if not exists public.career_match_items (
  id uuid primary key default gen_random_uuid(),
  career_match_id uuid not null,
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  path_id text not null,
  rank integer not null,
  fit_score numeric(5,2) not null,
  fit_label text not null,
  score_breakdown jsonb not null default '{}'::jsonb,
  fit_reason text not null,
  main_gap text not null,
  first_action_id text,
  recommended_project_id text,
  uncertainty jsonb not null default '{}'::jsonb,
  risk_notes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint career_match_items_match_user_fk
    foreign key (career_match_id, user_id)
    references public.career_matches(id, user_id)
    on delete cascade,
  constraint career_match_items_rank_positive check (rank > 0),
  constraint career_match_items_fit_score_range check (fit_score >= 0 and fit_score <= 100),
  constraint career_match_items_path_id_not_blank check (length(trim(path_id)) > 0),
  constraint career_match_items_fit_label_not_blank check (length(trim(fit_label)) > 0),
  constraint career_match_items_unique_rank unique (career_match_id, rank),
  constraint career_match_items_unique_path unique (career_match_id, path_id)
);

create table if not exists public.saved_paths (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  path_id text not null,
  status public.path_status not null default 'exploring',
  source_career_match_id uuid,
  source_match_item_id uuid,
  saved_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint saved_paths_id_user_id_key unique (id, user_id),
  constraint saved_paths_path_id_not_blank check (length(trim(path_id)) > 0),
  constraint saved_paths_match_fk
    foreign key (source_career_match_id)
    references public.career_matches(id)
    on delete set null,
  constraint saved_paths_match_item_fk
    foreign key (source_match_item_id)
    references public.career_match_items(id)
    on delete set null
);

create table if not exists public.roadmaps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  student_profile_id uuid not null,
  saved_path_id uuid,
  primary_path_id text not null,
  roadmap_template_id text,
  generator_version text not null,
  title text not null,
  time_horizon_weeks integer not null default 4,
  weekly_time_commitment_hours numeric(5,2),
  assumptions jsonb not null default '{}'::jsonb,
  status public.roadmap_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint roadmaps_id_user_id_key unique (id, user_id),
  constraint roadmaps_profile_user_fk
    foreign key (student_profile_id, user_id)
    references public.student_profiles(id, user_id)
    on delete cascade,
  constraint roadmaps_saved_path_fk
    foreign key (saved_path_id)
    references public.saved_paths(id)
    on delete set null,
  constraint roadmaps_primary_path_id_not_blank check (length(trim(primary_path_id)) > 0),
  constraint roadmaps_generator_version_not_blank check (length(trim(generator_version)) > 0),
  constraint roadmaps_title_not_blank check (length(trim(title)) > 0),
  constraint roadmaps_time_horizon_reasonable check (
    time_horizon_weeks > 0 and time_horizon_weeks <= 52
  ),
  constraint roadmaps_weekly_time_reasonable check (
    weekly_time_commitment_hours is null
    or (weekly_time_commitment_hours >= 0 and weekly_time_commitment_hours <= 80)
  )
);

create table if not exists public.roadmap_tasks (
  id uuid primary key default gen_random_uuid(),
  roadmap_id uuid not null,
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  week_index integer not null,
  position_index integer not null,
  action_id text,
  related_project_id uuid,
  related_project_template_id text,
  title text not null,
  description text,
  expected_output_type text,
  status public.task_status not null default 'not_started',
  due_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  metric_ids jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint roadmap_tasks_id_user_id_key unique (id, user_id),
  constraint roadmap_tasks_roadmap_user_fk
    foreign key (roadmap_id, user_id)
    references public.roadmaps(id, user_id)
    on delete cascade,
  constraint roadmap_tasks_week_index_positive check (week_index > 0),
  constraint roadmap_tasks_position_index_positive check (position_index > 0),
  constraint roadmap_tasks_title_not_blank check (length(trim(title)) > 0),
  constraint roadmap_tasks_expected_output_type_valid check (
    expected_output_type is null
    or expected_output_type in ('text', 'link', 'file', 'checklist')
  ),
  constraint roadmap_tasks_unique_position unique (roadmap_id, week_index, position_index)
);

create table if not exists public.user_projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  project_template_id text not null,
  primary_path_id text,
  source_roadmap_id uuid,
  source_task_id uuid,
  title text not null,
  selected_reason text,
  status public.project_status not null default 'not_started',
  current_step_number integer,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_projects_id_user_id_key unique (id, user_id),
  constraint user_projects_project_template_id_not_blank
    check (length(trim(project_template_id)) > 0),
  constraint user_projects_title_not_blank check (length(trim(title)) > 0),
  constraint user_projects_current_step_positive check (
    current_step_number is null or current_step_number > 0
  ),
  constraint user_projects_source_roadmap_fk
    foreign key (source_roadmap_id)
    references public.roadmaps(id)
    on delete set null,
  constraint user_projects_source_task_fk
    foreign key (source_task_id)
    references public.roadmap_tasks(id)
    on delete set null
);

alter table public.roadmap_tasks
  drop constraint if exists roadmap_tasks_related_project_user_fk;

alter table public.roadmap_tasks
  drop constraint if exists roadmap_tasks_related_project_fk;

alter table public.roadmap_tasks
  add constraint roadmap_tasks_related_project_fk
  foreign key (related_project_id)
  references public.user_projects(id)
  on delete set null;

create table if not exists public.project_step_progress (
  id uuid primary key default gen_random_uuid(),
  user_project_id uuid not null,
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  step_number integer not null,
  action_id text,
  title text not null,
  status public.task_status not null default 'not_started',
  submission_type text,
  submission_text text,
  source_url text,
  file_id uuid,
  ai_feedback text,
  rubric_scores jsonb not null default '{}'::jsonb,
  review_status public.project_review_status not null default 'not_reviewed',
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint project_step_progress_project_user_fk
    foreign key (user_project_id, user_id)
    references public.user_projects(id, user_id)
    on delete cascade,
  constraint project_step_progress_step_positive check (step_number > 0),
  constraint project_step_progress_title_not_blank check (length(trim(title)) > 0),
  constraint project_step_progress_submission_type_valid check (
    submission_type is null
    or submission_type in ('text', 'link', 'file', 'checklist')
  ),
  constraint project_step_progress_unique_step unique (user_project_id, step_number)
);

create table if not exists public.dashboard_metric_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  metric_id text not null,
  score numeric(5,2) not null,
  score_label text,
  reason text,
  input_signals jsonb not null default '{}'::jsonb,
  computation_version text not null,
  related_entity_type text,
  related_entity_id uuid,
  created_at timestamptz not null default now(),
  constraint dashboard_metric_snapshots_metric_id_not_blank
    check (length(trim(metric_id)) > 0),
  constraint dashboard_metric_snapshots_score_range check (score >= 0 and score <= 100),
  constraint dashboard_metric_snapshots_computation_version_not_blank
    check (length(trim(computation_version)) > 0),
  constraint dashboard_metric_snapshots_related_entity_type_valid check (
    related_entity_type is null
    or related_entity_type in ('profile', 'roadmap', 'project', 'match', 'advisor')
  )
);

create table if not exists public.advisor_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  student_profile_id uuid,
  active_roadmap_id uuid,
  active_user_project_id uuid,
  context_snapshot jsonb not null default '{}'::jsonb,
  advisor_version text not null,
  status public.advisor_session_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint advisor_sessions_id_user_id_key unique (id, user_id),
  constraint advisor_sessions_profile_fk
    foreign key (student_profile_id)
    references public.student_profiles(id)
    on delete set null,
  constraint advisor_sessions_roadmap_fk
    foreign key (active_roadmap_id)
    references public.roadmaps(id)
    on delete set null,
  constraint advisor_sessions_project_fk
    foreign key (active_user_project_id)
    references public.user_projects(id)
    on delete set null,
  constraint advisor_sessions_advisor_version_not_blank
    check (length(trim(advisor_version)) > 0)
);

create table if not exists public.advisor_messages (
  id uuid primary key default gen_random_uuid(),
  advisor_session_id uuid not null,
  user_id uuid not null references public.user_accounts(id) on delete cascade,
  role public.advisor_message_role not null,
  content text not null,
  intent text,
  risk_level public.risk_level not null default 'low',
  sources_used jsonb not null default '[]'::jsonb,
  structured_refs jsonb not null default '{}'::jsonb,
  recommended_next_action_id text,
  related_path_id text,
  related_project_id uuid,
  related_project_template_id text,
  created_at timestamptz not null default now(),
  constraint advisor_messages_session_user_fk
    foreign key (advisor_session_id, user_id)
    references public.advisor_sessions(id, user_id)
    on delete cascade,
  constraint advisor_messages_project_fk
    foreign key (related_project_id)
    references public.user_projects(id)
    on delete set null,
  constraint advisor_messages_content_not_blank check (length(trim(content)) > 0)
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.user_accounts(id) on delete set null,
  actor_type public.actor_type not null,
  action text not null,
  entity_type text not null,
  entity_id text,
  request_id text,
  before_snapshot_redacted jsonb,
  after_snapshot_redacted jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint audit_logs_action_not_blank check (length(trim(action)) > 0),
  constraint audit_logs_entity_type_not_blank check (length(trim(entity_type)) > 0)
);

-- ---------------------------------------------------------------------------
-- 4. Indexes
-- ---------------------------------------------------------------------------

create unique index if not exists user_accounts_email_unique_lower_idx
  on public.user_accounts (lower(email))
  where email is not null;

create index if not exists user_accounts_auth_user_id_idx
  on public.user_accounts (auth_user_id);

create unique index if not exists student_profiles_one_active_per_user_idx
  on public.student_profiles (user_id)
  where status = 'active';

create index if not exists student_profiles_user_stage_idx
  on public.student_profiles (user_id, student_stage);

create index if not exists profile_events_user_created_idx
  on public.profile_events (user_id, created_at desc);

create index if not exists career_matches_user_created_idx
  on public.career_matches (user_id, created_at desc);

create index if not exists career_match_items_match_rank_idx
  on public.career_match_items (career_match_id, rank);

create index if not exists career_match_items_user_path_idx
  on public.career_match_items (user_id, path_id);

create unique index if not exists saved_paths_one_primary_per_user_idx
  on public.saved_paths (user_id)
  where status = 'primary';

create index if not exists saved_paths_user_status_idx
  on public.saved_paths (user_id, status);

create index if not exists roadmaps_user_status_idx
  on public.roadmaps (user_id, status);

create index if not exists roadmaps_user_primary_path_idx
  on public.roadmaps (user_id, primary_path_id);

create unique index if not exists roadmaps_one_active_per_user_idx
  on public.roadmaps (user_id)
  where status = 'active';

create index if not exists roadmap_tasks_roadmap_week_idx
  on public.roadmap_tasks (roadmap_id, week_index, position_index);

create index if not exists roadmap_tasks_user_status_idx
  on public.roadmap_tasks (user_id, status);

create index if not exists user_projects_user_status_idx
  on public.user_projects (user_id, status);

create index if not exists user_projects_user_template_idx
  on public.user_projects (user_id, project_template_id);

create index if not exists project_step_progress_project_step_idx
  on public.project_step_progress (user_project_id, step_number);

create index if not exists project_step_progress_user_status_idx
  on public.project_step_progress (user_id, status);

create index if not exists dashboard_metric_snapshots_latest_idx
  on public.dashboard_metric_snapshots (user_id, metric_id, created_at desc);

create index if not exists advisor_sessions_user_status_idx
  on public.advisor_sessions (user_id, status, created_at desc);

create index if not exists advisor_messages_session_created_idx
  on public.advisor_messages (advisor_session_id, created_at);

create index if not exists advisor_messages_user_created_idx
  on public.advisor_messages (user_id, created_at desc);

create index if not exists consent_records_user_type_created_idx
  on public.consent_records (user_id, consent_type, created_at desc);

create index if not exists audit_logs_actor_created_idx
  on public.audit_logs (actor_user_id, created_at desc);

create index if not exists audit_logs_entity_idx
  on public.audit_logs (entity_type, entity_id);

-- ---------------------------------------------------------------------------
-- 5. updated_at triggers
-- ---------------------------------------------------------------------------

drop trigger if exists set_updated_at on public.user_accounts;
create trigger set_updated_at
before update on public.user_accounts
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.student_profiles;
create trigger set_updated_at
before update on public.student_profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.saved_paths;
create trigger set_updated_at
before update on public.saved_paths
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.roadmaps;
create trigger set_updated_at
before update on public.roadmaps
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.roadmap_tasks;
create trigger set_updated_at
before update on public.roadmap_tasks
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.user_projects;
create trigger set_updated_at
before update on public.user_projects
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.project_step_progress;
create trigger set_updated_at
before update on public.project_step_progress
for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.advisor_sessions;
create trigger set_updated_at
before update on public.advisor_sessions
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- 6. Row Level Security draft
-- ---------------------------------------------------------------------------

alter table public.user_accounts enable row level security;
alter table public.consent_records enable row level security;
alter table public.student_profiles enable row level security;
alter table public.profile_events enable row level security;
alter table public.career_matches enable row level security;
alter table public.career_match_items enable row level security;
alter table public.saved_paths enable row level security;
alter table public.roadmaps enable row level security;
alter table public.roadmap_tasks enable row level security;
alter table public.user_projects enable row level security;
alter table public.project_step_progress enable row level security;
alter table public.dashboard_metric_snapshots enable row level security;
alter table public.advisor_sessions enable row level security;
alter table public.advisor_messages enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists user_accounts_select_own on public.user_accounts;
create policy user_accounts_select_own
on public.user_accounts
for select
to authenticated
using (auth_user_id = auth.uid());

drop policy if exists user_accounts_insert_own on public.user_accounts;
create policy user_accounts_insert_own
on public.user_accounts
for insert
to authenticated
with check (auth_user_id = auth.uid());

drop policy if exists user_accounts_update_own on public.user_accounts;
create policy user_accounts_update_own
on public.user_accounts
for update
to authenticated
using (auth_user_id = auth.uid())
with check (auth_user_id = auth.uid());

-- Generic user-owned policies. These assume user_id references user_accounts.id.
-- Trusted server routes may still use the Supabase service role for demo users
-- and system-generated rows.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'consent_records',
    'student_profiles',
    'profile_events',
    'career_matches',
    'career_match_items',
    'saved_paths',
    'roadmaps',
    'roadmap_tasks',
    'user_projects',
    'project_step_progress',
    'dashboard_metric_snapshots',
    'advisor_sessions',
    'advisor_messages'
  ] loop
    execute format(
      'drop policy if exists %I on public.%I',
      table_name || '_select_own',
      table_name
    );
    execute format(
      'create policy %I on public.%I for select to authenticated using (user_id = public.current_app_user_id())',
      table_name || '_select_own',
      table_name
    );

    execute format(
      'drop policy if exists %I on public.%I',
      table_name || '_insert_own',
      table_name
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (user_id = public.current_app_user_id())',
      table_name || '_insert_own',
      table_name
    );
  end loop;
end $$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'consent_records',
    'student_profiles',
    'saved_paths',
    'roadmaps',
    'roadmap_tasks',
    'user_projects',
    'project_step_progress',
    'advisor_sessions'
  ] loop
    execute format(
      'drop policy if exists %I on public.%I',
      table_name || '_update_own',
      table_name
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using (user_id = public.current_app_user_id()) with check (user_id = public.current_app_user_id())',
      table_name || '_update_own',
      table_name
    );
  end loop;
end $$;

drop policy if exists audit_logs_select_own on public.audit_logs;
create policy audit_logs_select_own
on public.audit_logs
for select
to authenticated
using (actor_user_id = public.current_app_user_id());

-- No client insert/update/delete policies for audit_logs by default.
-- App server / service role should write audit rows.

-- ---------------------------------------------------------------------------
-- 7. Convenience view
-- ---------------------------------------------------------------------------

create or replace view public.latest_dashboard_metric_snapshots
with (security_invoker = true)
as
select distinct on (user_id, metric_id)
  id,
  user_id,
  metric_id,
  score,
  score_label,
  reason,
  input_signals,
  computation_version,
  related_entity_type,
  related_entity_id,
  created_at
from public.dashboard_metric_snapshots
order by user_id, metric_id, created_at desc;

comment on view public.latest_dashboard_metric_snapshots is
  'Latest dashboard metric snapshot per user and metric_id. Reads are still subject to underlying RLS.';

commit;
