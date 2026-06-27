# AI Student Growth Platform

This repository contains the MVP planning, content schema, seed knowledge base, data model, API contracts, and implementation plan for a Canada-focused AI student career and project planning platform.

The project was narrowed after an external GPT Pro review. V1 is now focused on a university explorer beachhead before expanding to high-school, graduate, and early-career modes.

## Product Scope

The first MVP is a student growth loop, not a generic chatbot:

```text
Onboarding -> Profile Summary -> Career Match -> Save Primary Path -> 4-week Roadmap -> Project Builder -> Growth Snapshot -> Advisor Lite
```

V1 primary ICP:

> Canadian university explorers in business/data/tech-adjacent majors who are unclear about career direction and lack project evidence.

Secondary modes:

- High-school explorer mode remains a future / secondary demo path.
- Recent graduates and early-career explorers remain future extensions.
- Product content stays Canada-wide, but go-to-market should start with campus clusters.

The product is not limited to BC, Vancouver, or a specific high-school grade.

Initial content directions:

- Economics
- Commerce
- Business
- Statistics
- Computer Science
- Data Science
- Cognitive Systems
- International Relations
- Undecided

## Repository Map

| File / Folder | Purpose |
| --- | --- |
| `PROJECT_PLAN_ZH.md` | Overall project plan and strategic framing |
| `GPT_PRO_OPTIMIZATION_SUMMARY_ZH.md` | Scope changes made after GPT Pro review |
| `MVP_ROADMAP_ZH.md` | MVP module order and delivery roadmap |
| `CONTENT_SCHEMA_ZH.md` | Structured KB schema for career paths, skills, projects, actions, metrics, sources, and relations |
| `kb/` | First seed knowledge base in YAML |
| `ICP_AND_USER_STORIES_ZH.md` | First ICP, demo personas, and user stories |
| `CAREER_MATCHER_RULES_ZH.md` | V1 rules-based career matching logic |
| `DEMO_SCRIPT_ZH.md` | Demo flow for university and high-school explorer personas |
| `DATA_SCHEMA_ZH.md` | Runtime product data schema |
| `ONBOARDING_FLOW_ZH.md` | Thin onboarding and progressive profile flow |
| `APP_DATA_MODEL_SQL_DRAFT.sql` | Supabase/Postgres draft schema |
| `API_CONTRACTS_ZH.md` | MVP API contracts and request/response examples |
| `IMPLEMENTATION_PLAN_ZH.md` | Real development order from scaffold to Supabase integration |

## Current Build Strategy

The implementation plan recommends:

1. Build a runnable app scaffold.
2. Load structured KB YAML server-side.
3. Use a mock runtime store to validate the full demo loop.
4. Implement mock APIs matching the final API contracts.
5. Build onboarding, career matcher, roadmap, project progress, Growth Snapshot, and Advisor Lite.
6. Connect Supabase only after the mock end-to-end loop works.

This avoids getting blocked by auth, RLS, database setup, or RAG before the product loop is proven.

## V1 Non-Goals

V1 does not include:

- Parent dashboard
- School admin
- Employer portal
- Auto-apply
- Job board
- Resume or transcript upload
- Full RAG ingestion
- Full Dashboard
- Payment
- Immigration, legal, medical, or mental-health advice
