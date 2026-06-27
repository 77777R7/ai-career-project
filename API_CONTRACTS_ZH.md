# API_CONTRACTS_ZH

日期：2026-06-26

更新：2026-06-27，根据 GPT Pro 评估，V1 API 先服务 Growth Snapshot 和 Advisor Lite；Full Dashboard、Basic RAG、Supabase production repository 后置。

## 1. 文档目的

本文件定义 AI Student Growth Platform 第一版 MVP 的 API contracts。

它承接：

- `DATA_SCHEMA_ZH.md`
- `APP_DATA_MODEL_SQL_DRAFT.sql`
- `ONBOARDING_FLOW_ZH.md`
- `CAREER_MATCHER_RULES_ZH.md`
- `DEMO_SCRIPT_ZH.md`

目标是把产品模块和数据库表对应起来，让前端、后端、AI 逻辑和 demo 都按照同一套接口实现。

MVP API 主线：

```text
/api/profile
/api/career-matches
/api/roadmaps
/api/projects
/api/dashboard   # V1 返回 Growth Snapshot
/api/advisor     # V1 返回 Advisor Lite
```

## 2. API 设计原则

### 2.1 API 服务产品闭环，不服务大平台幻想

第一版 API 只支持：

```text
Profile -> Career Match -> Save Primary Path -> Roadmap -> Project -> Growth Snapshot -> Advisor Lite
```

暂不支持：

- 家长端。
- 学校端。
- 雇主端。
- 自动投递。
- application tracker。
- resume / transcript 文件上传。
- 完整 RAG ingestion 管理后台。

### 2.2 前端不直接写核心状态表

前端不应该直接操作 Supabase 表。

前端调用产品 API，由服务端负责：

- 校验 request。
- 读取 KB。
- 写入 product runtime tables。
- 写入 `profile_events`。
- V1 可先写入轻量 event log；完整 `audit_logs` 后置。
- 触发 Growth Snapshot metric recompute。
- 执行 AI safety / risk rules。

### 2.3 API 返回用户可显示的数据，不返回原始大表 dump

接口应该返回前端需要展示和下一步跳转所需的数据。

不要把完整 `student_profiles`、`career_matches`、`advisor_messages` 的所有内部字段直接 dump 给前端。

### 2.4 KB ID 是稳定 contract

API 可以返回 KB refs：

```yaml
career_path.business_analyst
career_path.data_analyst
career_path.consultant
project.canadian_housing_cost_living_dashboard
action.define_project_question
metric.career_clarity
metric.project_readiness
metric.skill_readiness
```

前端可以用这些 ID 显示标题、图标、说明或跳转。KB 内容本身可以先由服务端读取 `kb/`，后续再导入数据库。

### 2.5 AI 结果必须可解释、可追踪

涉及 AI 或规则生成的 endpoint 必须返回：

- version。
- input snapshot 摘要。
- uncertainty。
- structured refs。
- next action。

这不是为了复杂，而是为了之后能够解释“为什么系统给了这个建议”。

## 3. Global Contract

### 3.1 Base URL

本地开发：

```text
http://localhost:3000/api
```

生产：

```text
https://{app-domain}/api
```

### 3.2 Content type

所有 request / response 默认：

```http
Content-Type: application/json
```

### 3.3 Auth model

V1 支持两种模式：

| 模式 | 说明 | 数据写入 |
| --- | --- | --- |
| Auth user | 用户已登录，有 Supabase Auth user | `user_accounts.auth_user_id` |
| Demo user | 用户未登录，服务端创建 demo user | `user_accounts.account_type = demo` |

建议：

- 真实长期保存使用 Auth user。
- Demo mode 可以先通过 server session / signed demo token 维持。
- Demo user 不应该依赖客户端绕过 RLS 直接写表。

### 3.4 Common success envelope

```json
{
  "ok": true,
  "data": {},
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 3.5 Common error envelope

```json
{
  "ok": false,
  "error": {
    "code": "validation_error",
    "message": "Some fields need attention.",
    "field_errors": {
      "main_question": "Main question is required."
    },
    "details": {},
    "request_id": "req_..."
  }
}
```

### 3.6 Common HTTP status

| Status | 用途 |
| --- | --- |
| `200` | 成功读取或更新 |
| `201` | 成功创建 |
| `400` | request 格式或业务校验失败 |
| `401` | 未登录或 demo session 无效 |
| `403` | 无权限访问该用户数据 |
| `404` | 资源不存在 |
| `409` | 状态冲突，例如没有 primary path 却生成 roadmap |
| `422` | 输入可解析，但无法生成可靠结果 |
| `500` | 未预期服务端错误 |

### 3.7 Common IDs

产品运行时 ID：

```json
{
  "profile_id": "uuid",
  "career_match_id": "uuid",
  "match_item_id": "uuid",
  "saved_path_id": "uuid",
  "roadmap_id": "uuid",
  "roadmap_task_id": "uuid",
  "project_id": "uuid",
  "project_step_id": "uuid",
  "advisor_session_id": "uuid",
  "advisor_message_id": "uuid"
}
```

KB refs：

```json
{
  "path_id": "career_path.business_analyst",
  "project_template_id": "project.canadian_housing_cost_living_dashboard",
  "action_id": "action.define_project_question",
  "metric_id": "metric.career_clarity"
}
```

### 3.8 Version fields

API response 中涉及规则生成时应包含版本：

```json
{
  "matcher_version": "career_matcher_v1_rules_2026_06_26",
  "roadmap_generator_version": "roadmap_generator_v1_2026_06_26",
  "dashboard_metrics_version": "dashboard_metrics_v1",
  "advisor_version": "advisor_v1_2026_06_26",
  "kb_version": "kb_seed_2026_06_26"
}
```

## 4. Endpoint Overview

| Endpoint | 主要职责 | 主要写入表 |
| --- | --- | --- |
| `/api/profile` | onboarding、profile summary、profile update | `user_accounts`, `student_profiles`, `profile_events`, `consent_records` |
| `/api/career-matches` | 生成 career match、保存 primary path | `career_matches`, `career_match_items`, `saved_paths` |
| `/api/roadmaps` | 生成 roadmap、更新 task 状态 | `roadmaps`, `roadmap_tasks` |
| `/api/projects` | 开始项目、更新 project step | `user_projects`, `project_step_progress`, `dashboard_metric_snapshots` |
| `/api/dashboard` | 读取 Growth Snapshot metrics | `dashboard_metric_snapshots` |
| `/api/advisor` | 创建 Advisor Lite session、发送消息 | `advisor_sessions`, `advisor_messages` |

完整 `audit_logs` 属于 Supabase / trust layer 增强，不作为 V1 mock loop 的硬前置。

## 5. `/api/profile`

### 5.1 目的

负责用户 profile 的创建、读取、更新和 summary 生成。

对应产品阶段：

```text
Onboarding -> Profile Summary
```

### 5.2 读写表

读取：

- `user_accounts`
- `student_profiles`
- `consent_records`

写入：

- `user_accounts`
- `student_profiles`
- `profile_events`
- `consent_records`
- `audit_logs`

可触发：

- `dashboard_metric_snapshots` for `metric.career_clarity`

### 5.3 `POST /api/profile`

用于提交首次 onboarding。

#### Request

```json
{
  "mode": "demo",
  "locale": "en-CA",
  "consents": [
    {
      "consent_type": "privacy_policy",
      "policy_version": "privacy_v1",
      "accepted": true
    },
    {
      "consent_type": "profile_personalization",
      "policy_version": "profile_personalization_v1",
      "accepted": true
    }
  ],
  "profile": {
    "student_type": "university_student",
    "student_stage": "university_beginner",
    "country": "Canada",
    "province": "all",
    "school": "Canadian university",
    "major": "Economics",
    "target_majors": [],
    "liked_subjects": ["economics", "business", "market analysis"],
    "disliked_subjects": ["pure coding"],
    "interested_industries": ["data", "business", "consulting"],
    "preferred_work_styles": ["analyzing information", "explaining ideas"],
    "skills": {
      "excel": "beginner",
      "sql": "none",
      "python": "none",
      "presentation": "beginner",
      "writing": "intermediate"
    },
    "projects": [],
    "internships": [],
    "extracurriculars": [],
    "short_term_goal": "Find a clearer internship direction before second year.",
    "long_term_goal": "Work in a business or data-related role.",
    "main_question": "I do not know whether I should explore data analyst, business analyst, or consulting.",
    "weekly_time_commitment_hours": 5
  }
}
```

#### Required fields

```yaml
profile.student_type
profile.student_stage
profile.country
profile.main_question
```

#### Server behavior

```text
validate request
create or resolve user_accounts
insert consent_records if provided
upsert student_profiles
insert profile_events: created or updated
generate profile_summary
insert profile_events: summary_generated
insert audit_logs: profile_created or profile_updated
optionally compute metric.career_clarity snapshot
```

#### Response

```json
{
  "ok": true,
  "data": {
    "user": {
      "user_id": "uuid",
      "account_type": "demo"
    },
    "profile": {
      "profile_id": "uuid",
      "profile_version": 1,
      "completed_profile": true,
      "student_type": "university_student",
      "student_stage": "university_beginner",
      "country": "Canada",
      "province": "all",
      "major": "Economics",
      "main_question": "I do not know whether I should explore data analyst, business analyst, or consulting.",
      "profile_summary": "You are a Canadian university Economics student exploring business, data, and consulting-related paths...",
      "data_quality_flags": {
        "missing_recommended_fields": [],
        "uncertainty_level": "low"
      }
    },
    "next": {
      "label": "Show my career matches",
      "action": "create_career_match",
      "href": "/career-match"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 5.4 `GET /api/profile`

读取当前用户 active profile。

#### Response

```json
{
  "ok": true,
  "data": {
    "profile": {
      "profile_id": "uuid",
      "profile_version": 1,
      "completed_profile": true,
      "student_type": "university_student",
      "student_stage": "university_beginner",
      "country": "Canada",
      "province": "all",
      "major": "Economics",
      "target_majors": [],
      "liked_subjects": ["economics", "business", "market analysis"],
      "disliked_subjects": ["pure coding"],
      "interested_industries": ["data", "business", "consulting"],
      "preferred_work_styles": ["analyzing information", "explaining ideas"],
      "skills": {
        "excel": "beginner",
        "sql": "none",
        "python": "none"
      },
      "projects": [],
      "internships": [],
      "short_term_goal": "Find a clearer internship direction before second year.",
      "weekly_time_commitment_hours": 5,
      "main_question": "I do not know whether I should explore data analyst, business analyst, or consulting.",
      "profile_summary": "You are a Canadian university Economics student exploring business, data, and consulting-related paths..."
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 5.5 `PATCH /api/profile`

用于用户编辑 profile。Advisor Lite proposed profile patch 属于后续增强，V1 不做自动提出/确认 profile patch。

#### Request

```json
{
  "patch_source": "user_edit",
  "profile_patch": {
    "preferred_work_styles": ["working with data", "explaining ideas"],
    "weekly_time_commitment_hours": 3
  },
  "regenerate_summary": true
}
```

#### Server behavior

```text
load active student_profile
validate allowed fields
increment profile_version
update student_profiles
insert profile_events: updated
if regenerate_summary: update profile_summary and insert summary_generated event
insert audit_logs: profile_updated
```

#### Response

```json
{
  "ok": true,
  "data": {
    "profile": {
      "profile_id": "uuid",
      "profile_version": 2,
      "profile_summary": "Updated summary...",
      "data_quality_flags": {
        "missing_recommended_fields": ["extracurriculars"],
        "uncertainty_level": "medium"
      }
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 5.6 `POST /api/profile/summary`

重新生成 profile summary，但不改变用户字段。

#### Request

```json
{
  "profile_id": "uuid",
  "summary_version": "profile_summary_v1_2026_06_26"
}
```

#### Response

```json
{
  "ok": true,
  "data": {
    "profile_id": "uuid",
    "profile_summary": "You are exploring how your interests could connect to future university programs and career paths.",
    "profile_summary_version": "profile_summary_v1_2026_06_26"
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 6. `/api/career-matches`

### 6.1 目的

负责生成 career match、返回推荐路径、保存 primary path。

对应产品阶段：

```text
Profile Summary -> Career Match -> Save Primary Path
```

### 6.2 读写表

读取：

- `student_profiles`
- `career_matches`
- `career_match_items`
- `saved_paths`
- KB career paths
- KB relations
- KB projects
- KB actions

写入：

- `career_matches`
- `career_match_items`
- `saved_paths`
- `dashboard_metric_snapshots`
- `audit_logs`

### 6.3 `POST /api/career-matches`

根据当前 profile 生成 top 3 career paths。

#### Request

```json
{
  "profile_id": "uuid",
  "force_regenerate": false,
  "matcher_version": "career_matcher_v1_rules_2026_06_26"
}
```

如果 `profile_id` 为空，服务端使用当前用户 active profile。

#### Server behavior

```text
load active student_profile
normalize profile
read KB career paths and relations
score candidate paths
create career_matches row
create career_match_items rows
insert audit_logs: career_match_generated
return top 3 with explanations and next action
```

#### Response

```json
{
  "ok": true,
  "data": {
    "career_match": {
      "career_match_id": "uuid",
      "profile_id": "uuid",
      "profile_version": 1,
      "matcher_version": "career_matcher_v1_rules_2026_06_26",
      "kb_version": "kb_seed_2026_06_26",
      "status": "completed",
      "uncertainty": {
        "missing_inputs": [],
        "uncertainty_level": "low"
      },
      "recommended_paths": [
        {
          "match_item_id": "uuid",
          "path_id": "career_path.business_analyst",
          "rank": 1,
          "title": "Business Analyst",
          "fit_score": 82,
          "fit_label": "Worth exploring",
          "score_breakdown": {
            "interest": 22,
            "skill": 12,
            "academic": 13,
            "evidence": 4,
            "goal": 14,
            "time": 8
          },
          "fit_reason": "Your Economics background, business interest, and dislike of pure coding make Business Analyst a practical first path to test.",
          "main_gap": "You need project evidence that shows structured analysis and communication.",
          "first_action": {
            "action_id": "action.define_project_question",
            "title": "Define a project research question"
          },
          "recommended_project": {
            "project_template_id": "project.canadian_housing_cost_living_dashboard",
            "title": "Canadian Housing and Cost of Living Dashboard"
          },
          "risk_notes": []
        }
      ]
    },
    "next": {
      "label": "Choose a path to explore",
      "action": "save_primary_path"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 6.4 `GET /api/career-matches/latest`

读取当前用户最新 match。

#### Response

同 `POST /api/career-matches` 的 `data.career_match`。

如果没有 match：

```json
{
  "ok": false,
  "error": {
    "code": "career_match_not_found",
    "message": "No career match has been generated yet.",
    "details": {
      "next_action": "create_career_match"
    },
    "request_id": "req_..."
  }
}
```

### 6.5 `GET /api/career-matches/:career_match_id`

读取指定 match run。

规则：

- 只能读取属于当前用户的 match。
- 返回 match items 和 saved path 状态。

### 6.6 `POST /api/career-matches/:career_match_id/save-primary`

保存用户选择的 primary path。

#### Request

```json
{
  "match_item_id": "uuid",
  "path_id": "career_path.business_analyst",
  "saved_reason": "This path feels like the best first test because it connects business and analysis."
}
```

#### Server behavior

```text
validate match item belongs to career_match and user
archive previous primary saved_path if exists
insert or update saved_paths with status primary
insert audit_logs: primary_path_saved
compute metric.career_clarity snapshot
return saved path and roadmap creation hint
```

#### Response

```json
{
  "ok": true,
  "data": {
    "saved_path": {
      "saved_path_id": "uuid",
      "path_id": "career_path.business_analyst",
      "status": "primary",
      "source_career_match_id": "uuid",
      "source_match_item_id": "uuid"
    },
    "dashboard_updates": [
      {
        "metric_id": "metric.career_clarity",
        "score": 45,
        "score_label": "Direction selected"
      }
    ],
    "next": {
      "label": "Build my 4-week roadmap",
      "action": "create_roadmap",
      "href": "/roadmap"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 7. `/api/roadmaps`

### 7.1 目的

负责生成用户自己的 4-week roadmap，并更新 task 状态。

对应产品阶段：

```text
Save Primary Path -> Roadmap
```

### 7.2 读写表

读取：

- `student_profiles`
- `saved_paths`
- `roadmaps`
- `roadmap_tasks`
- KB roadmaps
- KB actions
- KB projects

写入：

- `roadmaps`
- `roadmap_tasks`
- `audit_logs`
- optionally `dashboard_metric_snapshots`

### 7.3 `POST /api/roadmaps`

根据 primary path 生成 roadmap。

#### Request

```json
{
  "saved_path_id": "uuid",
  "time_horizon_weeks": 4,
  "weekly_time_commitment_hours": 5,
  "generator_version": "roadmap_generator_v1_2026_06_26"
}
```

如果 `saved_path_id` 为空，服务端使用当前用户 `status: primary` 的 saved path。

#### Server behavior

```text
load active profile
load primary saved_path
read KB roadmap template / action / project refs
archive previous active roadmap if needed
create roadmaps row
create roadmap_tasks rows
insert audit_logs: roadmap_generated
return roadmap with weekly tasks
```

#### Response

```json
{
  "ok": true,
  "data": {
    "roadmap": {
      "roadmap_id": "uuid",
      "title": "4-week Business Analyst exploration roadmap",
      "primary_path_id": "career_path.business_analyst",
      "time_horizon_weeks": 4,
      "weekly_time_commitment_hours": 5,
      "status": "active",
      "tasks": [
        {
          "roadmap_task_id": "uuid",
          "week_index": 1,
          "position_index": 1,
          "action_id": "action.define_project_question",
          "title": "Define a project research question",
          "description": "Choose one focused question your project will answer.",
          "expected_output_type": "text",
          "status": "not_started",
          "metric_ids": [
            "metric.career_clarity",
            "metric.project_readiness"
          ]
        }
      ]
    },
    "next": {
      "label": "Start first task",
      "action": "start_roadmap_task"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 7.4 `GET /api/roadmaps/active`

读取当前 active roadmap。

#### Response

返回 `roadmap` 和 `tasks`。

如果没有 active roadmap：

```json
{
  "ok": false,
  "error": {
    "code": "active_roadmap_not_found",
    "message": "No active roadmap exists yet.",
    "details": {
      "next_action": "create_roadmap"
    },
    "request_id": "req_..."
  }
}
```

### 7.5 `PATCH /api/roadmaps/:roadmap_id/tasks/:task_id`

更新 task 状态。

#### Request

```json
{
  "status": "done",
  "completion_note": "I defined a focused research question for the housing dashboard project.",
  "completed_at": "2026-06-26T12:00:00Z"
}
```

#### Server behavior

```text
validate task belongs to roadmap and user
update roadmap_tasks
insert audit_logs: roadmap_task_status_changed
if task affects metric_ids: optionally recompute dashboard metrics
```

#### Response

```json
{
  "ok": true,
  "data": {
    "task": {
      "roadmap_task_id": "uuid",
      "status": "done",
      "completed_at": "2026-06-26T12:00:00Z"
    },
    "dashboard_recompute_recommended": true
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 8. `/api/projects`

### 8.1 目的

负责把 KB project template 实例化为用户项目，并保存 project step progress。

对应产品阶段：

```text
Roadmap -> Project Builder -> Project Step Review
```

### 8.2 读写表

读取：

- `user_projects`
- `project_step_progress`
- `roadmap_tasks`
- `saved_paths`
- KB projects
- KB actions
- KB metrics

写入：

- `user_projects`
- `project_step_progress`
- `roadmap_tasks`
- `dashboard_metric_snapshots`
- `audit_logs`

### 8.3 `POST /api/projects`

开始一个用户项目。

#### Request

```json
{
  "project_template_id": "project.canadian_housing_cost_living_dashboard",
  "primary_path_id": "career_path.business_analyst",
  "source_roadmap_id": "uuid",
  "source_task_id": "uuid",
  "selected_reason": "This project can show analysis and communication evidence."
}
```

#### Server behavior

```text
validate project_template_id exists in KB
create user_projects row
create first project_step_progress row if template has first action
optionally link roadmap task related_project_id
insert audit_logs: project_started
compute metric.project_readiness snapshot
```

#### Response

```json
{
  "ok": true,
  "data": {
    "project": {
      "project_id": "uuid",
      "project_template_id": "project.canadian_housing_cost_living_dashboard",
      "title": "Canadian Housing and Cost of Living Dashboard",
      "primary_path_id": "career_path.business_analyst",
      "status": "in_progress",
      "current_step_number": 1,
      "steps": [
        {
          "project_step_id": "uuid",
          "step_number": 1,
          "action_id": "action.define_project_question",
          "title": "Define a project research question",
          "status": "not_started",
          "submission_type": "text"
        }
      ]
    },
    "dashboard_updates": [
      {
        "metric_id": "metric.project_readiness",
        "score": 20,
        "score_label": "Project selected"
      }
    ],
    "next": {
      "label": "Complete step 1",
      "action": "update_project_step"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 8.4 `GET /api/projects/active`

读取当前用户 active projects。

#### Response

```json
{
  "ok": true,
  "data": {
    "projects": [
      {
        "project_id": "uuid",
        "project_template_id": "project.canadian_housing_cost_living_dashboard",
        "title": "Canadian Housing and Cost of Living Dashboard",
        "status": "in_progress",
        "current_step_number": 1,
        "completed_steps": 0,
        "total_known_steps": 1,
        "latest_action_id": "action.define_project_question"
      }
    ]
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 8.5 `PATCH /api/projects/:project_id/steps/:step_id`

保存项目步骤进度或提交内容。

#### Request

```json
{
  "status": "done",
  "submission_type": "text",
  "submission_text": "How do housing prices differ across Vancouver neighbourhoods, and what factors may explain the difference?",
  "review_requested": true
}
```

#### Server behavior

```text
validate step belongs to project and user
update project_step_progress
if review_requested: generate lightweight ai_feedback and rubric_scores
update user_projects.current_step_number if needed
insert audit_logs: project_step_submitted
compute metric.project_readiness and metric.skill_readiness snapshots
```

#### Response

```json
{
  "ok": true,
  "data": {
    "step": {
      "project_step_id": "uuid",
      "step_number": 1,
      "action_id": "action.define_project_question",
      "status": "done",
      "submission_type": "text",
      "submission_text": "How do housing prices differ across Vancouver neighbourhoods, and what factors may explain the difference?",
      "ai_feedback": "This is focused enough for a beginner dashboard project. The next step is to choose a dataset that can answer it.",
      "rubric_scores": {
        "clarity": 4,
        "scope": 3,
        "feasibility": 4
      },
      "review_status": "ai_reviewed"
    },
    "dashboard_updates": [
      {
        "metric_id": "metric.project_readiness",
        "score": 35,
        "score_label": "Started"
      },
      {
        "metric_id": "metric.skill_readiness",
        "score": 25,
        "score_label": "Evidence building"
      }
    ],
    "next": {
      "label": "Choose a dataset",
      "action": "next_project_step",
      "action_id": "action.select_dataset"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 9. `/api/dashboard`

### 9.1 目的

负责读取用户成长状态和 Growth Snapshot metrics。V1 仍保留 `/api/dashboard` 路径名，方便后续扩展到 Full Dashboard。

对应产品阶段：

```text
Project Progress -> Growth Snapshot
```

### 9.2 读写表

读取：

- `student_profiles`
- `career_matches`
- `career_match_items`
- `saved_paths`
- `roadmaps`
- `roadmap_tasks`
- `user_projects`
- `project_step_progress`
- `dashboard_metric_snapshots`

写入：

- `dashboard_metric_snapshots`

### 9.3 `GET /api/dashboard`

读取 Growth Snapshot 当前状态。

#### Response

```json
{
  "ok": true,
  "data": {
    "summary": {
      "profile_completed": true,
      "primary_path_id": "career_path.business_analyst",
      "active_roadmap_id": "uuid",
      "active_project_id": "uuid"
    },
    "metrics": [
      {
        "metric_id": "metric.career_clarity",
        "score": 45,
        "score_label": "Direction selected",
        "reason": "You have completed your profile and selected one primary path to explore.",
        "computed_at": "2026-06-26T12:00:00Z"
      },
      {
        "metric_id": "metric.project_readiness",
        "score": 35,
        "score_label": "Started",
        "reason": "You have selected a beginner project and completed the first planning step.",
        "computed_at": "2026-06-26T12:00:00Z"
      },
      {
        "metric_id": "metric.skill_readiness",
        "score": 25,
        "score_label": "Evidence building",
        "reason": "You have started building evidence, but still need a finished artifact.",
        "computed_at": "2026-06-26T12:00:00Z"
      }
    ],
    "roadmap_progress": {
      "total_tasks": 4,
      "completed_tasks": 1,
      "current_week": 1
    },
    "project_progress": {
      "active_projects": 1,
      "completed_project_steps": 1,
      "latest_action_id": "action.define_project_question"
    },
    "next_best_action": {
      "source": "project",
      "action_id": "action.select_dataset",
      "title": "Choose a dataset"
    }
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 9.4 Internal recompute hook

重新计算 metrics。V1 不把 `POST /api/dashboard/recompute` 暴露给前端；它只是服务端内部事件可以调用的逻辑，例如保存 primary path、完成 roadmap task、提交 project step 后触发。

#### Internal input

```json
{
  "metric_ids": [
    "metric.career_clarity",
    "metric.project_readiness",
    "metric.skill_readiness"
  ],
  "reason": "project_step_completed"
}
```

如果 `metric_ids` 为空，服务端计算 MVP 默认 metrics。

#### Server behavior

```text
read latest profile, match, saved path, roadmap, project states
compute requested metrics
insert dashboard_metric_snapshots
return latest metric snapshots
```

#### Internal output

```json
{
  "ok": true,
  "data": {
    "metrics": [
      {
        "metric_id": "metric.project_readiness",
        "score": 35,
        "score_label": "Started",
        "reason": "You have selected a beginner project and completed the first planning step.",
        "computation_version": "dashboard_metrics_v1"
      }
    ]
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 10. `/api/advisor`

### 10.1 目的

负责 Advisor Lite session 和 messages。

Advisor Lite 的定位是增强入口，不是产品第一入口。

对应产品阶段：

```text
Growth Snapshot / Project / Roadmap -> Advisor Lite
```

### 10.2 读写表

读取：

- `student_profiles`
- `saved_paths`
- `career_matches`
- `roadmaps`
- `roadmap_tasks`
- `user_projects`
- `project_step_progress`
- `dashboard_metric_snapshots`
- KB refs
- optional RAG refs later

写入：

- `advisor_sessions`
- `advisor_messages`
- `profile_events` only after user confirms profile patch
- `audit_logs` for high-risk or blocked events

### 10.3 `POST /api/advisor/sessions`

创建 Advisor session。

#### Request

```json
{
  "entry_point": "dashboard",
  "active_roadmap_id": "uuid",
  "active_user_project_id": "uuid",
  "advisor_version": "advisor_v1_2026_06_26"
}
```

#### Server behavior

```text
load current profile summary
load saved primary path
load latest career match summary
load active roadmap and project progress
load latest dashboard metrics
create advisor_sessions with context_snapshot
return session and opening context
```

#### Response

```json
{
  "ok": true,
  "data": {
    "advisor_session": {
      "advisor_session_id": "uuid",
      "advisor_version": "advisor_v1_2026_06_26",
      "status": "active",
      "context_summary": {
        "profile_summary": "You are a Canadian university Economics student exploring business, data, and consulting-related paths...",
        "saved_primary_path": {
          "path_id": "career_path.business_analyst",
          "title": "Business Analyst"
        },
        "current_project_progress": {
          "project_template_id": "project.canadian_housing_cost_living_dashboard",
          "completed_project_steps": 1,
          "latest_action_id": "action.define_project_question"
        }
      }
    },
    "starter_prompts": [
      "What should I do next?",
      "Why did you recommend this path?",
      "How can I improve my project?"
    ]
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 10.4 `POST /api/advisor/messages`

发送用户消息，并生成 Advisor 回复。

#### Request

```json
{
  "advisor_session_id": "uuid",
  "message": {
    "content": "What should I do next this week?"
  }
}
```

#### Server behavior

```text
validate session belongs to user
insert advisor_messages role=user
load session context and latest structured state
classify intent and risk
if safe: generate assistant reply using profile + path + roadmap + project progress
if high risk or blocked: use safety response and audit log
insert advisor_messages role=assistant
return assistant message, structured refs, and optional proposed profile patch
```

#### Response

```json
{
  "ok": true,
  "data": {
    "user_message": {
      "advisor_message_id": "uuid",
      "role": "user",
      "content": "What should I do next this week?"
    },
    "assistant_message": {
      "advisor_message_id": "uuid",
      "role": "assistant",
      "intent": "ask_next_step",
      "risk_level": "low",
      "content": "Your next useful move is to choose the dataset for your housing dashboard. Keep the scope small: one public dataset, one question, and one chart that answers it.",
      "structured_refs": {
        "action_ids": ["action.select_dataset"],
        "project_template_ids": ["project.canadian_housing_cost_living_dashboard"],
        "metric_ids": ["metric.project_readiness"]
      },
      "recommended_next_action_id": "action.select_dataset",
      "sources_used": []
    },
    "proposed_profile_patch": null
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

### 10.5 Profile patch from Advisor

Advisor 不直接改 profile。

如果 Advisor 需要补问并得到用户回答，返回：

```json
{
  "proposed_profile_patch": {
    "preferred_work_styles": ["working with data", "explaining ideas"],
    "reason": "The user said they prefer analysis and explaining results."
  }
}
```

前端必须让用户确认后再调用：

```text
PATCH /api/profile
```

### 10.6 `GET /api/advisor/sessions/:advisor_session_id/messages`

读取 session messages。

#### Response

```json
{
  "ok": true,
  "data": {
    "advisor_session_id": "uuid",
    "messages": [
      {
        "advisor_message_id": "uuid",
        "role": "user",
        "content": "What should I do next this week?",
        "created_at": "2026-06-26T12:00:00Z"
      },
      {
        "advisor_message_id": "uuid",
        "role": "assistant",
        "intent": "ask_next_step",
        "risk_level": "low",
        "content": "Your next useful move is to choose the dataset for your housing dashboard...",
        "structured_refs": {
          "action_ids": ["action.select_dataset"]
        },
        "created_at": "2026-06-26T12:00:01Z"
      }
    ]
  },
  "meta": {
    "request_id": "req_...",
    "api_version": "v1",
    "warnings": []
  }
}
```

## 11. Error Codes

### 11.1 Common

```yaml
validation_error:
unauthorized:
forbidden:
not_found:
state_conflict:
internal_error:
```

### 11.2 Profile

```yaml
profile_not_found:
profile_incomplete:
unsupported_student_stage:
consent_required:
```

### 11.3 Career Match

```yaml
career_match_not_found:
career_match_generation_failed:
career_match_insufficient_signal:
match_item_not_found:
primary_path_save_failed:
```

### 11.4 Roadmap

```yaml
primary_path_required:
roadmap_not_found:
active_roadmap_not_found:
roadmap_generation_failed:
roadmap_task_not_found:
```

### 11.5 Project

```yaml
project_template_not_found:
project_not_found:
project_step_not_found:
project_step_update_failed:
```

### 11.6 Growth Snapshot

```yaml
metric_not_found:
growth_snapshot_recompute_failed:
```

### 11.7 Advisor

```yaml
advisor_session_not_found:
advisor_message_rejected:
advisor_high_risk_blocked:
advisor_generation_failed:
```

## 12. State Transition Rules

### 12.1 Profile

```text
no_profile -> completed_profile
completed_profile -> updated_profile
updated_profile -> new career match recommended
```

### 12.2 Career Match

```text
profile exists -> career_match completed
career_match completed -> primary path saved
primary path saved -> roadmap can be generated
```

### 12.3 Roadmap

```text
no active roadmap -> active roadmap
active roadmap task not_started -> in_progress -> done
active roadmap -> archived when regenerated
```

### 12.4 Project

```text
project template selected -> user_project in_progress
project step not_started -> in_progress -> done
project completed when required steps are done
```

### 12.5 Advisor

```text
session active -> messages appended
advisor proposed profile patch -> user confirms -> PATCH /api/profile
high risk message -> safe response + audit log
```

## 13. Security and Privacy Contract

### 13.1 User isolation

Every endpoint must enforce:

```text
requested resource belongs to current user
```

服务端不能只相信客户端传来的 `user_id`。

### 13.2 Demo mode

Demo mode 可以跑完整体验，但必须：

- 由服务端创建 demo user。
- 使用 signed session / token 识别 demo user。
- 不允许客户端任意传 `user_id` 写别人的数据。
- Demo 数据后续可以清理。

### 13.3 Audit log

这些行为必须写 `audit_logs`：

- profile created / updated。
- career match generated。
- primary path saved。
- roadmap generated。
- roadmap task status changed。
- project started。
- project step submitted。
- dashboard recompute failed。
- advisor high-risk response blocked。
- consent accepted / withdrawn。

### 13.4 Consent

以下功能需要 consent：

| 功能 | consent_type |
| --- | --- |
| 使用产品基础条款 | `terms_of_service` |
| 保存 profile 个性化数据 | `profile_personalization` |
| 使用 Advisor Lite | `advisor_lite` |
| 上传文件 | `user_uploaded_files` |
| 市场营销通知 | `marketing_communications` |
| 未成年人相关正式流程 | `guardian_or_parental_consent` |

V1 demo 可以不实现完整 guardian flow，但 schema 和 API 需要保留空间。

## 14. Frontend Route Mapping

| Frontend screen | API calls |
| --- | --- |
| `/onboarding` | `POST /api/profile` |
| `/profile/summary` | `GET /api/profile`, optional `POST /api/profile/summary` |
| `/career-match` | `POST /api/career-matches`, `GET /api/career-matches/latest` |
| `/career-match/:id` | `GET /api/career-matches/:career_match_id` |
| `/career-match/save` | `POST /api/career-matches/:career_match_id/save-primary` |
| `/roadmap` | `POST /api/roadmaps`, `GET /api/roadmaps/active` |
| `/roadmap/task` | `PATCH /api/roadmaps/:roadmap_id/tasks/:task_id` |
| `/project` | `POST /api/projects`, `GET /api/projects/active` |
| `/project/step` | `PATCH /api/projects/:project_id/steps/:step_id` |
| `/growth` or `/dashboard` | `GET /api/dashboard` |
| `/advisor` | `POST /api/advisor/sessions`, `POST /api/advisor/messages` |

## 15. MVP Demo API Sequence

Demo 最小调用顺序：

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

Demo 通过标准：

- `POST /api/profile` 返回 profile summary。
- `POST /api/career-matches` 返回 3 条 paths。
- save-primary 写入 `saved_paths`。
- `POST /api/roadmaps` 返回 4-week tasks。
- `POST /api/projects` 创建用户项目。
- project step 更新后 dashboard metric 改变。
- Advisor message 使用结构化上下文回答。

## 16. Non-goals For V1 API

V1 API 暂不做：

- `POST /api/uploads`
- `POST /api/rag/ingest`
- `GET /api/jobs`
- `POST /api/applications`
- `POST /api/auto-apply`
- parent dashboard API
- school admin API
- employer API
- payment API

这些不是不重要，而是会把 MVP 从 student growth loop 拉成大平台。

## 17. Open Decisions

实现前还需要确认：

1. Demo mode 用 cookie session、signed token，还是只在本地 prototype 用 mock user。
2. `POST /api/profile` 是否自动生成 profile summary，还是拆成 `POST /api/profile/summary`。
3. `POST /api/career-matches` 是否每次都新建 run，还是可复用同 profile_version 的最新 run。
4. Growth Snapshot metrics：V1 默认 event-driven internal recompute，`GET /api/dashboard` 缺 snapshot 时可 lazy recompute；不把 `POST /api/dashboard/recompute` 暴露给前端。
5. Advisor message 是否默认永久保存，还是设置 retention。
6. KB YAML 是 server runtime 读取，还是 build-time import 到 DB。
7. 前端是否需要单独的 `/api/kb/*` 轻量读取接口。

## 18. Next Recommended Step

完成 API contracts 后，下一步建议做：

> `IMPLEMENTATION_PLAN_ZH.md`

原因：

- 产品模块顺序已经定好。
- KB schema 和 seed 已经有。
- Data schema 和 SQL draft 已经有。
- API contracts 已经把前后端边界钉住。

下一步需要把实现拆成 sprint：

1. Project scaffold。
2. KB loader。
3. Mock API。
4. Onboarding UI。
5. Career Matcher service。
6. Roadmap service。
7. Project progress。
8. Growth Snapshot。
9. Advisor Lite。
10. Supabase integration。
