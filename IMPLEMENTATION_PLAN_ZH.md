# IMPLEMENTATION_PLAN_ZH

日期：2026-06-27

## 1. 文档目的

本文件把当前 AI Student Growth Platform 的规划文档拆成真正的开发执行顺序。

它承接：

- `MVP_ROADMAP_ZH.md`
- `CONTENT_SCHEMA_ZH.md`
- `ICP_AND_USER_STORIES_ZH.md`
- `CAREER_MATCHER_RULES_ZH.md`
- `DEMO_SCRIPT_ZH.md`
- `DATA_SCHEMA_ZH.md`
- `ONBOARDING_FLOW_ZH.md`
- `APP_DATA_MODEL_SQL_DRAFT.sql`
- `API_CONTRACTS_ZH.md`

第一版实现目标不是做完整大平台，而是跑通一个可演示、可测试、可继续扩展的 MVP 闭环：

```text
Onboarding -> Profile Summary -> Career Match -> Save Primary Path -> Roadmap -> Project Builder -> Dashboard -> AI Advisor
```

本文件之后，开发工作按这里的阶段执行。

## 2. 总实现原则

### 2.1 先跑通闭环，再接真实基础设施

第一版不要一上来卡在 Supabase、auth、RAG、部署、完整权限系统上。

推荐实现策略：

```text
local app scaffold
-> KB loader
-> in-memory / file-backed mock runtime store
-> mock API
-> full demo UI
-> service logic
-> tests
-> Supabase integration
```

这样可以先证明产品体验和业务逻辑，再替换数据层。

### 2.2 Mock data 不是假产品

V1 mock 不是随便写死页面。它必须使用真实字段名、真实 KB IDs、真实 API contracts。

允许 mock：

- user id。
- demo session。
- local runtime store。
- AI response stub。
- dashboard metric computation stub。

不允许 mock：

- 随便写不在 schema 里的字段。
- 前端绕过 API contract。
- Career Match 只写固定文案，不经过 matcher service。
- Dashboard 只显示静态数字，不读取状态。

### 2.3 KB YAML 先作为 source of truth

第一版结构化 KB 已经在 `kb/`：

- Career Paths
- Skills
- Roadmaps
- Projects
- Actions
- Metrics
- Sources
- Relations

开发初期直接用 server-side KB loader 读取 YAML。等 Supabase integration 阶段再决定是否 import 到数据库。

### 2.4 不把 AI Advisor 作为第一入口

第一屏不是 chatbot。

AI Advisor 只在用户已经有 profile、path、roadmap、project progress 之后出现，用来回答下一步问题。

### 2.5 不扩 scope

V1 不做：

- 家长端。
- 学校端。
- 雇主端。
- 自动投递。
- application tracker。
- resume / transcript upload。
- 完整 RAG ingestion。
- payment。
- job board。
- 移民 / 法律 / 医疗 / 心理专业建议。

## 3. 推荐技术路线

如果从零开始，推荐：

```yaml
frontend_backend: Next.js App Router
language: TypeScript
ui: React + Tailwind CSS
runtime_api: Next.js Route Handlers
validation: Zod
kb_loader: yaml parser
state_v1: in-memory/file-backed mock store
database_later: Supabase Postgres
auth_later: Supabase Auth + demo session
tests: Vitest + Playwright
```

原因：

- API contracts 可以直接落成 route handlers。
- 前端和后端类型可以共享。
- Supabase 后面接入成本低。
- Demo 可以快速跑起来。

如果后续发现已有 app scaffold，则优先贴合已有技术栈，不强行重建。

## 4. Phase 0: Preflight And Repo Setup

### 4.1 目标

确认项目目录、文档、KB seed 和执行入口，为代码实现做准备。

### 4.2 输入文档

- `PROJECT_PLAN_ZH.md`
- `MVP_ROADMAP_ZH.md`
- `CONTENT_SCHEMA_ZH.md`
- `DATA_SCHEMA_ZH.md`
- `API_CONTRACTS_ZH.md`
- `DEMO_SCRIPT_ZH.md`
- `kb/`

### 4.3 具体任务

1. 确认 workspace 当前是否已有 package/app。
2. 如果没有，进入 Phase 1 创建 scaffold。
3. 确认 `kb/**/*.yaml` 都能解析。
4. 确认 demo 所需 KB IDs 存在。
5. 建立 `docs/status` 或 README 中的当前实现状态。

### 4.4 验收标准

- 能列出所有现有项目文件。
- 能解析所有 YAML seed。
- 能确认以下 refs 存在：

```yaml
career_path.business_analyst
career_path.data_analyst
career_path.consultant
project.vancouver_housing_dashboard
action.define_project_question
action.select_dataset
metric.career_clarity
metric.project_readiness
metric.skill_readiness
```

### 4.5 不做

- 不改产品 scope。
- 不先接 Supabase。
- 不先做 landing page。

## 5. Phase 1: Project Scaffold

### 5.1 目标

创建可以运行的 web app 基础骨架。

### 5.2 产物

建议目录：

```text
app/
  api/
  onboarding/
  profile/
  career-match/
  roadmap/
  project/
  dashboard/
  advisor/
components/
lib/
  kb/
  mock/
  services/
  schemas/
  types/
tests/
```

### 5.3 具体任务

1. 初始化 Next.js + TypeScript 项目。
2. 配置 lint / format / test。
3. 配置 Tailwind 或现有 UI 基础。
4. 建立基础 app shell。
5. 建立 route placeholders：

```text
/onboarding
/profile/summary
/career-match
/roadmap
/project
/dashboard
/advisor
```

6. 建立 API route placeholders：

```text
/api/profile
/api/career-matches
/api/roadmaps
/api/projects
/api/dashboard
/api/advisor
```

### 5.4 验收标准

- `npm run dev` 可以启动。
- 首页直接进入产品体验，不做营销 landing page。
- 所有 placeholder 页面可访问。
- 所有 placeholder API 返回统一 envelope：

```json
{
  "ok": true,
  "data": {},
  "meta": {
    "api_version": "v1"
  }
}
```

### 5.5 测试

```text
npm run lint
npm run test
```

后续有 UI 后再加 Playwright smoke test。

## 6. Phase 2: KB Loader

### 6.1 目标

让 app 能从 `kb/` 读取结构化内容，而不是在前端硬编码 career path / project / metric。

### 6.2 产物

建议文件：

```text
lib/kb/load-kb.ts
lib/kb/types.ts
lib/kb/validate-kb.ts
lib/kb/get-career-paths.ts
lib/kb/get-projects.ts
lib/kb/get-actions.ts
lib/kb/get-metrics.ts
```

### 6.3 具体任务

1. 读取 `kb/**/*.yaml`。
2. 按实体类型建立 map：

```ts
careerPathsById
skillsById
projectsById
actionsById
metricsById
sourcesById
relations
taxonomies
```

3. 校验所有 `id` 唯一。
4. 校验 `kb/relations.yaml` 引用存在。
5. 提供 typed query helpers：

```ts
getCareerPath(id)
listActiveCareerPaths()
getProjectTemplate(id)
getAction(id)
getMetric(id)
```

### 6.4 验收标准

- 所有 KB YAML 能被 loader 读取。
- 所有 demo refs 能 resolve。
- loader 不依赖浏览器环境，只在 server side 使用。
- 缺失引用时测试失败。

### 6.5 测试

重点测试：

- YAML parse。
- ID uniqueness。
- relation reference integrity。
- demo reference integrity。

### 6.6 不做

- 不做 vector DB。
- 不做 full-text RAG。
- 不把 KB 全部发到前端。

## 7. Phase 3: Mock Runtime Store

### 7.1 目标

在不接 Supabase 的情况下，模拟 `APP_DATA_MODEL_SQL_DRAFT.sql` 里的核心 runtime data。

### 7.2 产物

建议文件：

```text
lib/mock/mock-store.ts
lib/mock/demo-users.ts
lib/types/runtime.ts
lib/schemas/runtime.ts
```

### 7.3 需要模拟的表

```text
user_accounts
student_profiles
profile_events
career_matches
career_match_items
saved_paths
roadmaps
roadmap_tasks
user_projects
project_step_progress
dashboard_metric_snapshots
advisor_sessions
advisor_messages
consent_records
audit_logs
```

### 7.4 具体任务

1. 定义 TypeScript runtime types，对齐 SQL 字段。
2. 定义 Zod schemas，对齐 API request。
3. 建立 mock store CRUD helpers。
4. 建立 demo session helper。
5. 建立 append-only audit helper。
6. 建立 reset demo state helper，便于演示重新开始。

### 7.5 验收标准

- API 可以通过 mock store 读写状态。
- Demo User A / B 可以完整保存。
- 状态不是只存在前端 component state。
- 刷新页面后如果使用 file-backed store，demo 状态可恢复；如果使用 in-memory store，必须有清晰 reset 行为。

### 7.6 不做

- 不做真实 auth。
- 不做真实 RLS。
- 不写入 Supabase。

## 8. Phase 4: Mock API

### 8.1 目标

按照 `API_CONTRACTS_ZH.md` 实现 mock API，让前端先接真实 endpoint 形状。

### 8.2 实现 endpoint

Profile：

```text
POST /api/profile
GET /api/profile
PATCH /api/profile
POST /api/profile/summary
```

Career Match：

```text
POST /api/career-matches
GET /api/career-matches/latest
GET /api/career-matches/:career_match_id
POST /api/career-matches/:career_match_id/save-primary
```

Roadmap：

```text
POST /api/roadmaps
GET /api/roadmaps/active
PATCH /api/roadmaps/:roadmap_id/tasks/:task_id
```

Projects：

```text
POST /api/projects
GET /api/projects/active
PATCH /api/projects/:project_id/steps/:step_id
```

Dashboard：

```text
GET /api/dashboard
POST /api/dashboard/recompute
```

Advisor：

```text
POST /api/advisor/sessions
POST /api/advisor/messages
GET /api/advisor/sessions/:advisor_session_id/messages
```

### 8.3 具体任务

1. 实现统一 success/error envelope。
2. 实现 request validation。
3. 实现 demo user resolution。
4. 实现 service 层调用，不在 route handler 里写业务逻辑。
5. 每个 mutation 写 audit log。
6. API response 不直接 dump 整张表。

### 8.4 验收标准

- 按 demo sequence 调用 API 可以成功：

```text
POST /api/profile
POST /api/career-matches
POST /api/career-matches/:career_match_id/save-primary
POST /api/roadmaps
POST /api/projects
PATCH /api/projects/:project_id/steps/:step_id
GET /api/dashboard
POST /api/advisor/sessions
POST /api/advisor/messages
```

- 每一步都有状态写入 mock store。
- 错误 response 使用统一格式。
- 无 primary path 时生成 roadmap 返回 `409 state_conflict`。

### 8.5 测试

建议先写 API service tests：

- profile create。
- career match generate。
- save primary path。
- roadmap generate。
- project start + step submit。
- dashboard recompute。
- advisor session + message。

## 9. Phase 5: Onboarding UI

### 9.1 目标

实现用户第一真实行动：完成薄 profile，并看到 profile summary。

### 9.2 页面

```text
/onboarding
/profile/summary
```

### 9.3 UI flow

对齐 `ONBOARDING_FLOW_ZH.md`：

```text
Step 0: Consent / Demo Entry
Step 1: Current Situation
Step 2: Direction Signal
Step 3: Skills and Evidence
Step 4: Time and Goal
Step 5: Profile Summary Confirmation
```

### 9.4 具体任务

1. 建立 multi-step form。
2. 每屏最多一个主问题。
3. 支持 `Not sure yet` / `Skip for now`。
4. 不要求高中用户填写具体年级。
5. 不限制 BC / Vancouver。
6. 提交调用 `POST /api/profile`。
7. Summary 页面调用 `GET /api/profile`。
8. CTA 指向 Career Match：

```text
Show my career matches
```

### 9.5 验收标准

- Demo User A 可以完成 onboarding。
- Demo User B 可以完成 onboarding。
- 用户不填 `grade_level` 也可以继续。
- 用户不上传 resume / transcript / LinkedIn。
- `POST /api/profile` 返回 summary。
- Summary 不是泛泛 AI 文案，必须引用输入事实。

### 9.6 UI 验证

用 Playwright 检查：

- desktop onboarding flow。
- mobile onboarding flow。
- 文本不溢出按钮或卡片。
- 无 landing page 抢占第一屏。

## 10. Phase 6: Career Matcher Service

### 10.1 目标

实现 V1 rules-based Career Matcher。

### 10.2 产物

建议文件：

```text
lib/services/career-matcher/normalize-profile.ts
lib/services/career-matcher/score-path.ts
lib/services/career-matcher/generate-match.ts
lib/services/career-matcher/explain-match.ts
```

### 10.3 输入

- `student_profiles`
- KB career paths。
- `kb/relations.yaml`
- KB projects。
- KB actions。

### 10.4 输出

- `career_matches`
- `career_match_items`
- `saved_paths` after save-primary。
- `dashboard_metric_snapshots` for `metric.career_clarity` after primary path save。

### 10.5 具体任务

1. 实现 profile normalization。
2. 实现 skill level normalization。
3. 实现 candidate path generation。
4. 实现 score dimensions：

```yaml
interest: 25
skill: 20
academic: 15
evidence: 15
goal: 15
time: 10
```

5. 返回 top 3 paths。
6. 每条 path 返回：

```yaml
fit_score:
fit_label:
score_breakdown:
fit_reason:
main_gap:
first_action:
recommended_project:
uncertainty:
risk_notes:
```

7. 实现 save-primary service。

### 10.6 验收标准

- Demo User A 推荐：

```yaml
- career_path.business_analyst
- career_path.data_analyst
- career_path.consultant
```

- Demo User B 使用 exploration 语气。
- 缺失 recommended fields 时不阻止结果。
- 不出现 “you are not fit”。
- 不承诺 offer、薪资、录取。
- 每条推荐都有 next action。

### 10.7 测试

重点测试：

- high school user 不被拒绝。
- undecided user 仍返回探索路径。
- `disliked_subjects: pure coding` 不硬性排除 Data Analyst。
- fit score 在 0-100。
- top 3 rank 不重复。
- all returned KB refs exist。

## 11. Phase 7: Roadmap Service

### 11.1 目标

把用户保存的 primary path 转成 4-week roadmap。

### 11.2 产物

建议文件：

```text
lib/services/roadmap/generate-roadmap.ts
lib/services/roadmap/update-task.ts
lib/services/roadmap/select-roadmap-template.ts
```

### 11.3 输入

- Active student profile。
- Primary saved path。
- KB roadmap templates。
- KB actions。
- KB projects。
- Weekly time commitment。

### 11.4 输出

- `roadmaps`
- `roadmap_tasks`
- task status updates。

### 11.5 具体任务

1. 找到当前 primary saved path。
2. 根据 `primary_path_id` 选择 roadmap template。
3. 如果没有完全匹配模板，生成 fallback 4-week roadmap。
4. 每个 task 关联 action / project / metric refs。
5. 更新 task 状态时写 audit log。
6. 重新生成 roadmap 时 archive previous active roadmap。

### 11.6 验收标准

- 用户保存 primary path 后可以生成 roadmap。
- Roadmap 至少有 4 周任务。
- Week 1 有明确 first action。
- Task status 支持：

```text
not_started -> in_progress -> done
blocked / need_help / skipped
```

- 无 primary path 时不生成 roadmap，返回 state conflict。

### 11.7 测试

- valid primary path generates roadmap。
- missing primary path returns error。
- roadmap regeneration archives previous active roadmap。
- task status update persists。

## 12. Phase 8: Project Progress

### 12.1 目标

让用户从 roadmap 进入 Project Builder，并完成第一个项目步骤。

### 12.2 页面

```text
/project
/project/:project_id
```

### 12.3 服务

建议文件：

```text
lib/services/projects/start-project-instance.ts
lib/services/projects/update-user-project-step.ts
lib/services/projects/review-user-project-step.ts
```

### 12.4 输入

- KB project template。
- KB actions。
- source roadmap / task。
- user submission。

### 12.5 输出

- `user_projects`
- `project_step_progress`
- `dashboard_metric_snapshots`

### 12.6 具体任务

1. 实现 `POST /api/projects`。
2. 实现 project detail UI。
3. 实现 Step 1 submission：

```yaml
action_id: action.define_project_question
submission_type: text
```

4. 实现 lightweight AI / rule feedback。
5. 更新 project readiness。
6. 返回 next action：

```yaml
action.select_dataset
```

### 12.7 验收标准

- 用户能从 roadmap task 进入 project。
- `project.vancouver_housing_dashboard` 能实例化为 user project。
- 用户能提交 research question。
- Step 1 完成后 dashboard metric 改变。
- AI feedback 不承诺结果，只做项目质量反馈。

### 12.8 测试

- project template exists。
- user project created。
- step submission stored。
- rubric scores stored。
- project readiness recomputed。

## 13. Phase 9: Dashboard

### 13.1 目标

Dashboard 显示用户真实状态，而不是静态漂亮数字。

### 13.2 页面

```text
/dashboard
```

### 13.3 服务

建议文件：

```text
lib/services/dashboard/compute-career-clarity.ts
lib/services/dashboard/compute-project-readiness.ts
lib/services/dashboard/compute-skill-readiness.ts
lib/services/dashboard/get-dashboard.ts
```

### 13.4 MVP metrics

第一版只做：

```yaml
metric.career_clarity
metric.project_readiness
metric.skill_readiness
```

以后再补：

```yaml
metric.interview_readiness
```

### 13.5 具体任务

1. 实现 `GET /api/dashboard`。
2. 实现 `POST /api/dashboard/recompute`。
3. 读取 latest snapshots。
4. 如果没有 snapshot，可以 lazy recompute。
5. 显示：

```yaml
profile_completed:
primary_path:
active_roadmap:
active_project:
metrics:
roadmap_progress:
project_progress:
next_best_action:
```

### 13.6 验收标准

- 完成 profile 后 career clarity 有初始状态。
- 保存 primary path 后 career clarity 上升。
- 开始 project 后 project readiness 改变。
- 完成 Step 1 后 project readiness 再改变。
- Dashboard 的 next best action 指向真实 action。

### 13.7 测试

- empty state。
- profile-only state。
- matched + saved path state。
- project step completed state。
- metric snapshots latest selection。

## 14. Phase 10: AI Advisor

### 14.1 目标

实现一个基于结构化上下文的 Advisor，而不是通用聊天框。

### 14.2 页面

```text
/advisor
```

### 14.3 服务

建议文件：

```text
lib/services/advisor/create-session.ts
lib/services/advisor/build-context.ts
lib/services/advisor/classify-intent.ts
lib/services/advisor/generate-response.ts
lib/services/advisor/safety.ts
```

### 14.4 输入

- Profile summary。
- Saved primary path。
- Latest career match。
- Active roadmap。
- Current project progress。
- Dashboard metrics。
- KB refs。

### 14.5 输出

- `advisor_sessions`
- `advisor_messages`
- optional proposed profile patch。
- audit log for high-risk / blocked cases。

### 14.6 具体任务

1. 实现 `POST /api/advisor/sessions`。
2. 生成 `context_snapshot`。
3. 实现 starter prompts。
4. 实现 `POST /api/advisor/messages`。
5. Advisor 回答必须引用结构化状态。
6. Advisor 不直接修改 profile，只返回 proposed patch。
7. 实现 basic safety rules：

```yaml
no_offer_guarantee:
no_admission_guarantee:
no_immigration_legal_conclusion:
no_medical_or_mental_health_advice:
no_shame_language:
```

### 14.7 验收标准

- Advisor 能回答 “What should I do next this week?”
- 回答使用 profile + path + roadmap + project progress。
- 回答包含 `recommended_next_action_id`。
- 高风险问题返回 safe boundary。
- Advisor 不作为 app 第一入口。

### 14.8 测试

- advisor session context contains required objects。
- next-step question returns action ref。
- match explanation question returns path refs。
- high-risk immigration/legal question is blocked or redirected safely。
- proposed profile patch requires user confirmation。

## 15. Phase 11: Supabase Integration

### 15.1 目标

把 mock runtime store 替换成真实 Supabase/Postgres，同时保持 API contract 不变。

### 15.2 输入

- `APP_DATA_MODEL_SQL_DRAFT.sql`
- 已稳定的 mock API services。
- 已通过的 demo flow。

### 15.3 具体任务

1. 创建 Supabase project。
2. 在临时数据库验证 SQL draft。
3. 调整 migration：

```text
schemas
enums
tables
indexes
triggers
RLS policies
```

4. 建立 Supabase client。
5. 建立 repository layer：

```text
lib/repositories/profile-repository.ts
lib/repositories/career-match-repository.ts
lib/repositories/roadmap-repository.ts
lib/repositories/project-repository.ts
lib/repositories/dashboard-repository.ts
lib/repositories/advisor-repository.ts
```

6. API services 改为通过 repository 读写。
7. 保留 mock repository 作为测试和 local demo fallback。
8. 接入 Supabase Auth 或 demo session。
9. 验证 RLS。

### 15.4 验收标准

- API contract 不变。
- Demo sequence 用 Supabase backend 能完整跑通。
- 用户只能读写自己的数据。
- `audit_logs` 由服务端写入。
- `dashboard_metric_snapshots` 能保存历史。
- mock mode 仍可用于本地开发。

### 15.5 测试

- migration apply on clean DB。
- seed demo user。
- full API demo sequence。
- RLS isolation test。
- delete/archive behavior smoke test。

### 15.6 不做

- 不把 KB 全量迁入 DB，除非 YAML loader 已成为性能或部署问题。
- 不做 production RAG。
- 不做文件上传。

## 16. Phase 12: Basic RAG Later

### 16.1 触发条件

只有当以下都完成后再做：

- Profile flow 稳定。
- Career Matcher 稳定。
- Roadmap / Project / Dashboard 稳定。
- Advisor 能使用结构化上下文回答。

### 16.2 第一版 RAG 目标

RAG 只给 AI Advisor 提供可引用资料，不替代结构化 KB。

### 16.3 具体任务

1. 为 KB source 生成 chunks。
2. 加 citation refs。
3. Advisor response 显示 sources used。
4. 建 `rag_retrieval_runs`。

### 16.4 不做

- 不让 RAG 直接决定 career match。
- 不让 RAG 直接生成 dashboard score。
- 不抓取未授权内容。

## 17. Cross-Phase Data Contract

### 17.1 Runtime object order

```text
user_accounts
student_profiles
career_matches
career_match_items
saved_paths
roadmaps
roadmap_tasks
user_projects
project_step_progress
dashboard_metric_snapshots
advisor_sessions
advisor_messages
```

### 17.2 Mutation side effects

| 用户动作 | 必须写入 |
| --- | --- |
| Complete onboarding | `student_profiles`, `profile_events`, `audit_logs` |
| Generate career match | `career_matches`, `career_match_items`, `audit_logs` |
| Save primary path | `saved_paths`, `dashboard_metric_snapshots`, `audit_logs` |
| Generate roadmap | `roadmaps`, `roadmap_tasks`, `audit_logs` |
| Start project | `user_projects`, `project_step_progress`, `dashboard_metric_snapshots`, `audit_logs` |
| Submit project step | `project_step_progress`, `dashboard_metric_snapshots`, `audit_logs` |
| Open advisor | `advisor_sessions` |
| Send advisor message | `advisor_messages`, optionally `audit_logs` |

## 18. End-to-End Demo Acceptance Criteria

MVP demo 通过的最低标准：

1. 用户从 `/onboarding` 开始，不需要 landing page。
2. 用户完成薄 profile。
3. 系统生成 profile summary。
4. 系统生成 3 条 career matches。
5. 用户保存一个 primary path。
6. 系统生成 4-week roadmap。
7. 用户开始一个 project。
8. 用户完成 `action.define_project_question`。
9. Dashboard 根据真实状态更新。
10. Advisor 能回答下一步，并引用当前 profile/path/roadmap/project。

Demo 失败条件：

- 只有静态页面，没有 API 状态。
- 只有 chatbot，没有平台闭环。
- Career Match 无法解释原因。
- Roadmap 只是长文本，不是 task list。
- Dashboard 是硬编码数字。
- Advisor 不知道用户当前状态。
- 出现焦虑、羞辱、保证录取、保证 offer、移民法律结论。

## 19. Recommended Sprint Split

### Sprint 1: Runnable Shell + KB

范围：

- Project scaffold。
- KB loader。
- Mock store。
- API envelope。

完成线：

- App runs locally。
- KB refs resolve。
- Basic API health works。

### Sprint 2: Profile + Career Match

范围：

- Onboarding UI。
- Profile API。
- Career matcher service。
- Save primary path。

完成线：

- Demo User A / B can get 3 paths。

### Sprint 3: Roadmap + Project

范围：

- Roadmap service。
- Roadmap UI。
- Project Builder。
- Step 1 submission。

完成线：

- User can save path, generate roadmap, start project, complete first action。

### Sprint 4: Dashboard + Advisor

范围：

- Dashboard metrics。
- Advisor context。
- Advisor message flow。
- Safety boundaries。

完成线：

- Full demo loop passes with mock backend。

### Sprint 5: Supabase Integration

范围：

- SQL migration。
- Repository layer。
- Auth/demo session。
- RLS verification。

完成线：

- Full demo loop passes with Supabase backend。

## 20. Verification Checklist Before Real Users

必须完成：

- YAML KB validation。
- API contract tests。
- Career matcher rule tests。
- End-to-end demo test。
- Mobile onboarding screenshot check。
- Dashboard state transition test。
- Advisor safety test。
- Supabase RLS test if DB is connected。

需要人工 review：

- Onboarding wording。
- Career match explanation。
- High-school exploration language。
- Dashboard score labels。
- Advisor safety boundary wording。

## 21. Open Decisions Before Coding

开始代码前可以先默认，但需要记录：

1. 是否从零创建 Next.js app。
2. Mock store 使用 in-memory 还是 file-backed JSON。
3. Demo mode 使用 cookie session 还是固定 demo id。
4. Profile summary 先 rule-based，还是接 LLM。
5. Advisor V1 先 stub/rule-based，还是接 LLM。
6. Supabase 是第一个可跑版本后接，还是一开始就建项目。

建议默认：

```yaml
app: create Next.js app if no existing scaffold
mock_store: file-backed JSON for demo stability
demo_mode: signed cookie or server session
profile_summary_v1: rule-based template first
advisor_v1: rule-based/stub first, LLM later
supabase: after mock full loop passes
```

## 22. Immediate Next Step

下一步进入代码实现时，先做：

> Phase 1: Project Scaffold

第一轮代码目标：

```text
create runnable app
add route placeholders
add API health envelope
add KB loader skeleton
verify local dev server
```

完成后再进入：

```text
Phase 2: KB Loader
Phase 3: Mock Runtime Store
Phase 4: Mock API
```
