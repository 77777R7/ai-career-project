# CONTENT_SCHEMA_ZH

日期：2026-06-26

## 1. 文档目的

本文件定义 AI Student Growth Platform 第一版 KB 的内容结构。

这里的 KB 不是一堆文章，也不是把网页资料丢进 vector database。它是产品的成长逻辑引擎，负责支撑：

> Career Path Matcher -> Roadmap Generator -> Project Builder -> Growth Dashboard -> AI Advisor -> Basic RAG

第一版 KB 的目标不是覆盖所有职业，而是让 MVP 的核心闭环稳定运行：

> 学生填写 profile -> 系统推荐 career path -> 生成 roadmap -> 推荐 project -> 学生完成 action -> dashboard 更新 -> AI Advisor 给下一步建议

因此，每条内容都必须满足至少一个产品用途：

- 帮学生做方向判断。
- 生成 next action。
- 支撑 roadmap。
- 支撑 project builder。
- 支撑 dashboard scoring。
- 支撑 AI Advisor 回答。
- 提供来源、版权或合规依据。

## 2. Non-goals

本文件不做以下事情：

- 不定义最终 Supabase / Postgres 数据库 schema。
- 不定义用户数据 schema。
- 不定义完整 AI prompt。
- 不定义 UI 设计稿。
- 不提供法律、移民、医疗、心理或财务建议。
- 不覆盖完整职业数据库。
- 不定义学校端、家长端、雇主端集成。

本文件只定义第一版内容资产的结构，使内容能被前端展示、AI 稳定调用、roadmap 生成、project builder 执行和 dashboard 评分。

## 3. KB 在产品中的位置

### 3.1 KB 内容层先做

KB 内容层从阶段 0 就开始搭建。它包括：

- Career Paths
- Skills
- Roadmap Templates
- Project Templates
- Action Templates
- Growth Metrics
- Knowledge Sources
- Relationship Links

这些内容不依赖 RAG 才能使用。前端和业务逻辑可以直接读取结构化实体。

### 3.2 RAG 检索层后接

Basic RAG 放在 AI Advisor 基本跑通之后接入。RAG 层包括：

- Knowledge Chunks
- Embeddings
- Retrieval
- Citation display

RAG 的作用是帮助 AI Advisor 引用可靠资料，不负责替代 Career Path、Roadmap、Project、Metric 等结构化实体。

### 3.3 三层 KB 架构

第一版 KB 分三层：

| 层级 | 内容 | 作用 |
| --- | --- | --- |
| Layer 1: Structured Product KB | Career Paths, Skills, Roadmaps, Projects, Actions, Metrics | 产品逻辑层 |
| Layer 2: Source KB | Knowledge Sources, license, attribution, authority | 可信与合规层 |
| Layer 3: RAG Chunk KB | Chunks, embeddings, citations | AI 回答检索层 |

不要把这三层混在一起。Career Path 是结构化实体，不是 chunk。Career Path 的 summary、daily_tasks、risks 可以生成 chunks，但主实体必须保留结构。

## 4. KB 总体结构

MVP 内容主类为 7 类，另加 2 个支撑结构：

1. Career Paths
2. Skills
3. Roadmap Templates
4. Project Templates
5. Action Templates
6. Growth Metrics / Rubrics
7. Knowledge Sources
8. RAG-Ready Chunks
9. Relationship Schema

核心关系：

```text
Career Path
  -> Skills
  -> Roadmap Templates
  -> Project Templates
  -> Action Templates
  -> Growth Metrics
  -> Knowledge Sources

Project Template
  -> Steps
  -> Actions
  -> Skills
  -> Metrics
  -> Sources

Roadmap Template
  -> Milestones
  -> Actions
  -> Projects
  -> Metrics
```

## 5. 全局字段规范

所有 KB 实体都应包含以下全局字段。

```yaml
id:
title:
canonical_slug:
status:
version:
locale:
country:
province:
audience:
student_stage:
tags:
owner:
created_at:
updated_at:
last_reviewed_at:
next_review_due:
source_ids:
risk_level:
review_status:
content_maturity:
visibility:
ai_usage:
compliance_notes:
change_log:
```

字段说明：

| 字段 | 说明 |
| --- | --- |
| `id` | 稳定结构化 ID，不能随标题变化 |
| `title` | 展示名称 |
| `canonical_slug` | URL 和导入用 slug |
| `status` | 内容状态 |
| `version` | 内容版本，例如 `1.0.0` |
| `locale` | 语言和地区，例如 `en-CA`, `zh-CN` |
| `country` | 适用国家，MVP 默认 `Canada` |
| `province` | 适用省份，例如 `BC`, `ON`, `all` |
| `audience` | 适用用户类型 |
| `student_stage` | 学生阶段 |
| `tags` | 检索和筛选标签 |
| `owner` | 内容负责人 |
| `created_at` | 创建日期 |
| `updated_at` | 更新时间 |
| `last_reviewed_at` | 最近审核日期 |
| `next_review_due` | 下次审核日期 |
| `source_ids` | 关联来源 |
| `risk_level` | 内容风险等级 |
| `review_status` | 审核状态 |
| `content_maturity` | 内容成熟度 |
| `visibility` | 可见范围 |
| `ai_usage` | AI 调用规则 |
| `compliance_notes` | 合规说明 |
| `change_log` | 版本变更记录 |

## 6. ID 命名规范

ID 必须稳定、可读、可跨模块引用。

推荐格式：

```text
career_path.data_analyst
career_path.business_analyst
skill.sql
skill.excel
roadmap.data_analyst.university_beginner
project.vancouver_housing_dashboard
action.define_project_question
metric.project_readiness
source.statcan_open_license
chunk.source_statcan_labour_market.001
```

禁止格式：

```text
career1
Data Analyst 1
project-new-final-v2
data analyst
```

命名规则：

- 全小写。
- 用英文 snake_case。
- 用点号表达实体类型。
- 不在 ID 里使用空格。
- 不把版本号写进 ID。
- 标题可以变，ID 不随标题变。

## 7. Taxonomy 枚举规范

### 7.1 status

```yaml
status:
  - draft
  - active
  - archived
  - deprecated
```

### 7.2 review_status

```yaml
review_status:
  - unreviewed
  - internally_reviewed
  - student_tested
  - expert_reviewed
  - needs_revision
```

### 7.3 content_maturity

```yaml
content_maturity:
  - seed
  - internally_reviewed
  - student_validated
  - expert_reviewed
  - deprecated
```

AI 可以根据 `content_maturity` 调整 confidence。`seed` 内容不能被表达成权威结论。

### 7.4 risk_level

```yaml
risk_level:
  - low
  - medium
  - high
```

定义：

- `low`: 普通职业信息、技能建议、项目建议。
- `medium`: 影响重要选择，但不是法律、医疗、心理、移民或财务结论。
- `high`: 涉及法律、移民、心理健康、医疗、财务投资、身份状态、保证录取或保证 offer。

高风险内容不能给结论，只能提供官方资源、问题清单和 human advisor 转介。

### 7.5 audience

```yaml
audience:
  - high_school_student
  - university_student
  - recent_graduate
  - international_student
  - parent
  - advisor
```

MVP 默认主 audience：

```yaml
audience:
  - university_student
  - international_student
```

### 7.6 student_stage

```yaml
student_stage:
  - high_school_explorer
  - university_beginner
  - university_mid
  - university_job_search
  - recent_graduate
  - early_career
```

### 7.7 visibility

```yaml
visibility:
  - public
  - student_visible
  - internal
  - ai_only
  - admin_only
```

### 7.8 source_type

```yaml
source_type:
  - original
  - government
  - public_data
  - official_career_resource
  - academic
  - company
  - university
  - community
  - interview
  - user_generated
```

### 7.9 allowed_usage

```yaml
allowed_usage:
  - store_full_text
  - store_metadata_only
  - summarize
  - quote_short_excerpt
  - link_only
  - generate_chunks
  - commercial_use_allowed
  - commercial_use_restricted
```

## 8. AI Usage Contract

所有可被 AI 调用的内容都必须包含 `ai_usage`。

```yaml
ai_usage:
  used_by:
    - career_path_matcher
    - roadmap_generator
    - project_builder
    - advisor_chat
    - dashboard_scoring
  prompt_fields:
    - summary
    - required_skills
    - common_challenges
    - first_project_recommendation
  display_fields:
    - title
    - summary
    - daily_tasks
    - required_skills
  retrieval_priority: high
  allowed_response_modes:
    - explain
    - recommend
    - compare
    - summarize
  restricted_response_modes:
    - guarantee_outcome
    - legal_advice
    - immigration_advice
    - medical_advice
    - mental_health_treatment
    - financial_investment_advice
  user_visible: true
```

目的：

- 避免 AI 把内部 notes 展示给用户。
- 避免 AI 把 seed 内容当权威结论。
- 避免 AI 把 salary_note 说成承诺。
- 避免 AI 把 common_challenges 说成对学生的否定。
- 避免 AI 在高风险场景给结论。

## 9. Career Path Schema

### 9.1 用途

Career Path 支撑：

- Career Path Matcher
- Career Explorer
- Roadmap Generator
- Project Recommender
- Advisor Chat
- Dashboard scoring

### 9.2 Schema

```yaml
id:
title:
summary:
related_majors:
daily_tasks:
best_fit_for:
common_challenges:
reflection_questions:
support_strategies:
required_skills:
recommended_courses:
high_school_preparation:
university_preparation:
entry_level_roles:
internship_keywords:
project_ideas:
first_project_recommendation:
career_progression:
salary_note:
risks_and_challenges:
misconceptions:
alternative_paths:
canadian_context:
source_ids:
ai_usage:
```

### 9.3 字段说明

| 字段 | 说明 |
| --- | --- |
| `related_majors` | 常见相关专业 |
| `best_fit_for` | 可能适合的兴趣、行为和目标 |
| `common_challenges` | 这条路径常见挑战，不写成“不适合谁” |
| `reflection_questions` | 帮学生自测兴趣的问题 |
| `support_strategies` | 如果有挑战，可以怎样低风险尝试 |
| `first_project_recommendation` | 第一推荐项目 |
| `career_progression` | entry/mid/advanced 发展路径 |
| `misconceptions` | 常见误解 |
| `canadian_context` | 加拿大本地语境 |

### 9.4 特别规则

不要使用 `less_fit_for`。这个字段容易让 AI 输出“你不适合某职业”。统一改为：

- `common_challenges`
- `reflection_questions`
- `support_strategies`

安全表达示例：

```yaml
common_challenges:
  - This path often requires comfort with messy data and repeated analysis.
reflection_questions:
  - Do you enjoy finding patterns in unclear information?
support_strategies:
  - Start with a small spreadsheet project before deciding whether this path fits you.
```

### 9.5 Career Path 示例

```yaml
id: career_path.data_analyst
title: Data Analyst
canonical_slug: data-analyst
status: active
version: 1.0.0
locale: en-CA
country: Canada
province: all
audience:
  - university_student
  - international_student
student_stage:
  - university_beginner
  - university_mid
tags:
  - data
  - business
  - analytics
summary: Data analysts use data to help organizations understand problems, measure performance, and make better decisions.
related_majors:
  - Economics
  - Commerce
  - Statistics
  - Computer Science
  - Data Science
daily_tasks:
  - Clean and organize data.
  - Build reports or dashboards.
  - Explain findings to business teams.
best_fit_for:
  - Students who like structured problem-solving.
  - Students interested in business decisions and evidence.
common_challenges:
  - The work can involve repeated data cleaning and detail checking.
  - Students may need to become comfortable with SQL or spreadsheet formulas.
reflection_questions:
  - Do you enjoy finding patterns in messy information?
  - Are you willing to learn practical tools like SQL and Excel?
required_skills:
  - skill.excel
  - skill.sql
  - skill.data_visualization
  - skill.data_storytelling
first_project_recommendation:
  project_id: project.vancouver_housing_dashboard
  reason: Strong beginner project for students with business, economics, or city-data interests.
canadian_context:
  - Entry roles may use titles such as reporting analyst, BI intern, analytics intern, or business analyst intern.
source_ids:
  - source.jobbank_career_planning
risk_level: low
content_maturity: seed
visibility: student_visible
ai_usage:
  used_by:
    - career_path_matcher
    - roadmap_generator
    - project_builder
    - advisor_chat
  prompt_fields:
    - summary
    - required_skills
    - common_challenges
    - first_project_recommendation
  display_fields:
    - title
    - summary
    - daily_tasks
    - required_skills
```

## 10. Skill Schema

### 10.1 用途

Skill 支撑：

- Career Path matching
- Roadmap prerequisites
- Project requirements
- Dashboard skill readiness
- Advisor recommendations

### 10.2 Schema

```yaml
id:
name:
category:
summary:
related_career_paths:
prerequisite_skills:
beginner_definition:
intermediate_definition:
advanced_definition:
evidence_examples:
proof_artifacts:
learning_resources:
assessment_method:
dashboard_metric_links:
source_ids:
ai_usage:
```

### 10.3 字段说明

| 字段 | 说明 |
| --- | --- |
| `prerequisite_skills` | 先修技能 |
| `evidence_examples` | 学生如何证明这个技能 |
| `proof_artifacts` | 可展示成果，如 dashboard、memo、deck |
| `dashboard_metric_links` | 影响哪些 dashboard metric |

### 10.4 Skill 示例

```yaml
id: skill.sql
name: SQL
category: data
summary: A query language used to retrieve, filter, group, and analyze structured data.
related_career_paths:
  - career_path.data_analyst
  - career_path.business_analyst
prerequisite_skills:
  - skill.spreadsheet_basics
beginner_definition: Can understand tables and write simple SELECT and WHERE queries.
intermediate_definition: Can use JOIN, GROUP BY, aggregation, and filtering for business questions.
advanced_definition: Can design multi-step queries, validate outputs, and optimize analysis workflows.
evidence_examples:
  - Wrote SQL queries for a public dataset.
  - Used SQL output in a dashboard or insight memo.
proof_artifacts:
  - sql_query_file
  - dashboard
  - written_insight_memo
dashboard_metric_links:
  - metric.skill_readiness
  - metric.project_readiness
risk_level: low
content_maturity: seed
```

## 11. Roadmap Template Schema

### 11.1 用途

Roadmap Template 不应该是自由文本。它必须能变成任务、进度和 dashboard 信号。

### 11.2 Schema

```yaml
id:
career_path_id:
student_stage:
target_outcome:
assumptions:
time_budget_variants:
three_month_plan:
six_month_plan:
twelve_month_plan:
weekly_task_examples:
required_skills:
recommended_projects:
common_blockers:
adjustment_rules:
source_ids:
ai_usage:
```

### 11.3 Milestone 结构

```yaml
milestones:
  - milestone_id:
    title:
    target_skills:
    recommended_actions:
    recommended_project_id:
    completion_criteria:
    related_metric_ids:
```

### 11.4 Roadmap 示例

```yaml
id: roadmap.data_analyst.university_beginner
career_path_id: career_path.data_analyst
student_stage: university_beginner
target_outcome: Build a beginner data analyst portfolio signal within 8-12 weeks.
assumptions:
  - Student can commit 3-5 hours per week.
  - Student has basic spreadsheet familiarity.
time_budget_variants:
  low:
    weekly_hours: 1-2
    recommendation: Focus on exploration and one small spreadsheet project.
  medium:
    weekly_hours: 3-5
    recommendation: Complete one portfolio project in 8-12 weeks.
  high:
    weekly_hours: 6-10
    recommendation: Add SQL practice, networking, and interview preparation.
three_month_plan:
  milestones:
    - milestone_id: milestone.sql_foundation
      title: Build SQL foundation
      target_skills:
        - skill.sql
      recommended_actions:
        - action.learn_sql_select
        - action.complete_sql_practice
      completion_criteria:
        - Student can write SELECT, WHERE, and GROUP BY queries.
      related_metric_ids:
        - metric.skill_readiness
    - milestone_id: milestone.first_dashboard
      title: Complete first dashboard project
      recommended_project_id: project.vancouver_housing_dashboard
      completion_criteria:
        - Student completes the first three project steps.
      related_metric_ids:
        - metric.project_readiness
```

## 12. Project Template Schema

### 12.1 用途

Project Template 是 MVP 最重要的产品资产。它证明平台不是 advice tool，而是 execution platform。

### 12.2 Schema

```yaml
id:
title:
target_career_paths:
difficulty:
estimated_time:
skills:
prerequisites:
project_goal:
final_outputs:
steps:
rubric:
resume_bullet_templates:
linkedin_post_template:
interview_story_template:
data_sources:
ai_support_level:
academic_integrity_notes:
source_ids:
ai_usage:
```

### 12.3 Project Step Schema

```yaml
step_number:
title:
objective:
estimated_time:
required_tools:
input_needed:
instructions:
expected_output:
completion_checklist:
ai_help_prompt:
review_rubric:
common_mistakes:
next_step_trigger:
related_metric_ids:
```

### 12.4 AI 支持边界

每个项目都必须声明 AI 能帮什么，不能帮什么。

```yaml
ai_support_level:
  allowed:
    - explain_concepts
    - review_student_output
    - suggest_next_steps
    - generate_resume_bullet_from_completed_work
  not_allowed:
    - fabricate_results
    - complete_project_without_student_input
    - claim_student_did_work_they_did_not_do
```

### 12.5 学术诚信说明

```yaml
academic_integrity_notes:
  - This project is designed for portfolio learning.
  - Do not submit AI-generated work as school coursework unless allowed by your instructor.
```

### 12.6 Project 示例

```yaml
id: project.vancouver_housing_dashboard
title: Vancouver Housing Affordability Dashboard
target_career_paths:
  - career_path.data_analyst
  - career_path.business_analyst
difficulty: beginner_to_intermediate
estimated_time: 4-6 weeks
skills:
  - skill.excel
  - skill.data_visualization
  - skill.data_storytelling
prerequisites:
  skills:
    - skill.spreadsheet_basics
  tools:
    - Excel or Google Sheets
  accounts:
    - none
project_goal: Analyze housing affordability trends in Vancouver and explain the findings through a dashboard and short insight memo.
final_outputs:
  - cleaned_dataset
  - dashboard
  - insight_summary
  - portfolio_page
  - resume_bullet
  - interview_story
steps:
  - step_number: 1
    title: Define the research question
    objective: Choose a focused question for the project.
    estimated_time: 30 minutes
    required_tools:
      - Google Docs
    input_needed:
      - career_path
      - student_interest
    instructions:
      - Choose a topic related to housing affordability.
      - Write one question that can be answered with data.
    expected_output:
      type: text
      description: A 1-2 sentence research question.
    completion_checklist:
      - The question is specific.
      - The question can be answered with available data.
      - The question connects to a real-world decision.
    ai_help_prompt: Help the student refine their research question without doing the project for them.
    review_rubric:
      clarity: 0-3
      feasibility: 0-3
      relevance: 0-3
    common_mistakes:
      - Question is too broad.
      - Question cannot be answered with available data.
    related_metric_ids:
      - metric.project_readiness
```

## 13. Action Template Schema

### 13.1 用途

长期成长平台跟踪的基本单位不是 content，而是 action。

Action Template 支撑：

- Roadmap weekly tasks
- Project steps
- Dashboard progress
- AI Advisor next action
- Retention loop

### 13.2 Schema

```yaml
id:
title:
description:
action_type:
student_stage:
career_path_ids:
skill_ids:
estimated_time:
difficulty:
prerequisites:
completion_criteria:
evidence_required:
related_metric_ids:
ai_support_prompt:
source_ids:
ai_usage:
```

### 13.3 action_type

```yaml
action_type:
  - onboarding
  - career_exploration
  - skill_learning
  - project_step
  - resume_output
  - networking
  - interview_prep
  - reflection
  - application
```

### 13.4 Action 示例

```yaml
id: action.define_project_question
title: Define your project research question
description: Write a focused question your project will answer.
action_type: project_step
student_stage:
  - university_beginner
career_path_ids:
  - career_path.data_analyst
skill_ids:
  - skill.data_storytelling
estimated_time: 30 minutes
difficulty: beginner
completion_criteria:
  - Student writes a 1-2 sentence research question.
evidence_required:
  - text_submission
related_metric_ids:
  - metric.project_readiness
ai_support_prompt: Help the student narrow the question while preserving their own thinking.
```

## 14. Growth Metric Schema

### 14.1 用途

Growth Metrics 让 Dashboard 可计算，而不是 AI 随机说一个百分比。

### 14.2 Schema

```yaml
id:
name:
description:
related_student_stage:
related_career_paths:
input_signals:
scoring_rules:
score_bands:
next_action_rules:
risk_notes:
source_ids:
ai_usage:
```

### 14.3 第一版 Metric

MVP 先做 7 个：

1. Career Clarity
2. Skill Readiness
3. Project Readiness
4. Resume Readiness
5. Networking Readiness
6. Interview Readiness
7. Execution Consistency

### 14.4 Metric 示例

```yaml
id: metric.project_readiness
name: Project Readiness
description: Measures whether a student has career-relevant project evidence.
related_student_stage:
  - university_beginner
  - university_mid
  - university_job_search
related_career_paths:
  - career_path.data_analyst
  - career_path.business_analyst
input_signals:
  - selected_project
  - completed_project_steps
  - final_outputs_created
  - resume_bullet_created
  - interview_story_created
scoring_rules:
  - condition: selected_project == true
    points: 20
  - condition: completed_project_steps >= 3
    points: 25
  - condition: final_outputs_created == true
    points: 25
  - condition: resume_bullet_created == true
    points: 15
  - condition: interview_story_created == true
    points: 15
score_bands:
  - range: 0-30
    label: Needs a starting project
  - range: 31-70
    label: Building evidence
  - range: 71-100
    label: Portfolio-ready
next_action_rules:
  - if_score_below: 30
    recommend: Choose one beginner project from your primary career path.
risk_notes:
  - Do not frame low readiness as failure. Use growth-oriented language.
```

## 15. Knowledge Source Schema

### 15.1 用途

Knowledge Sources 是来源治理层。它回答：

- 资料来自哪里？
- 能不能入库？
- 能不能商用？
- 要不要署名？
- 能不能生成 chunks？
- 风险等级是什么？

### 15.2 Schema

```yaml
id:
source_name:
url:
source_type:
publisher:
license:
license_url:
terms_url:
can_store_text:
can_use_commercially:
can_modify:
attribution_required:
attribution_text:
allowed_usage:
risk_level:
authority_level:
region_scope:
last_checked:
update_frequency:
ingestion_status:
content_owner_contact:
is_user_generated:
notes:
```

### 15.3 allowed_usage 分级

Green：

- 可入库。
- 可摘要。
- 可检索。
- 可在商业产品中使用，按许可署名。

Yellow：

- 只存 metadata、摘要和链接。
- 不全文入库。
- 不复制完整内容。

Red：

- 不使用。
- 不入库。
- 不生成 chunks。

### 15.4 Source 示例

```yaml
id: source.statcan_open_license
source_name: Statistics Canada Open Licence
url: https://www.statcan.gc.ca/en/terms-conditions/open-licence
source_type: government
publisher: Statistics Canada
license: Statistics Canada Open Licence
license_url: https://www.statcan.gc.ca/en/terms-conditions/open-licence
terms_url: https://www.statcan.gc.ca/en/terms-conditions
can_store_text: true
can_use_commercially: true
can_modify: true
attribution_required: true
attribution_text: Source: Statistics Canada.
allowed_usage:
  - store_metadata_only
  - summarize
  - generate_chunks
  - commercial_use_allowed
risk_level: low
authority_level: official
region_scope: Canada
last_checked: 2026-06-26
update_frequency: yearly
ingestion_status: metadata_only
is_user_generated: false
notes: Use according to official licence and attribution requirements.
```

## 16. RAG-Ready Chunk Schema

### 16.1 用途

Chunks 是 AI Advisor 的检索单位。Chunks 不替代结构化实体。

### 16.2 Schema

```yaml
id:
source_id:
parent_entity_type:
parent_entity_id:
title:
chunk_type:
content:
embedding_text:
display_text:
summary:
topic:
career_path_ids:
skill_ids:
student_stage:
country:
province:
risk_level:
safety_policy_tags:
retrieval_priority:
source_url:
citation_text:
license:
valid_from:
valid_until:
token_count:
```

### 16.3 chunk_type

```yaml
chunk_type:
  - fact
  - guidance
  - project_step
  - warning
  - definition
  - source_summary
```

### 16.4 safety_policy_tags

```yaml
safety_policy_tags:
  - career_general
  - education_general
  - immigration
  - legal
  - mental_health
  - medical
  - financial_investment
  - minors
```

高风险 tag 的 chunk 只能用于 redirect、source navigation 或 question preparation，不能用于给结论。

## 17. Relationship Schema

### 17.1 用途

Relationship Schema 让 KB 从文档库变成产品数据库。

它回答：

- 某 career path 需要哪些核心技能？
- 某 skill 对哪些职业重要？
- 某 project 证明哪些技能？
- 某 action 完成后影响哪些 dashboard metric？
- 某 source 支撑了哪个字段？

### 17.2 推荐关系文件

可以先放在：

```text
kb/relations.yaml
```

### 17.3 关系示例

```yaml
career_path_skills:
  - career_path_id: career_path.data_analyst
    skill_id: skill.sql
    importance: core
    required_level: intermediate
    weight: 0.25

career_path_projects:
  - career_path_id: career_path.data_analyst
    project_id: project.vancouver_housing_dashboard
    fit_level: beginner
    proves_skills:
      - skill.data_visualization
      - skill.data_storytelling
      - skill.excel

roadmap_projects:
  - roadmap_template_id: roadmap.data_analyst.university_beginner
    project_id: project.vancouver_housing_dashboard
    recommended_stage: first_project

action_metric_links:
  - action_id: action.define_project_question
    metric_id: metric.project_readiness
    effect:
      type: points
      value: 5

source_entity_links:
  - source_id: source.jobbank_career_planning
    entity_type: career_path
    entity_id: career_path.data_analyst
    supports_field: canadian_context
```

## 18. Seed Content Scope

第一版不要平均用力。要有深内容和浅内容。

### 18.1 Tier 1: 必须高质量完成

Career Paths：

1. Data Analyst
2. Business Analyst
3. Software Engineer
4. Product Manager
5. Consultant
6. Finance Analyst

Skills：

- 15 个核心 skills。

Roadmaps：

- 6 个核心 roadmap templates。

Projects：

- 6 个 project templates。

Knowledge Sources：

- 15 条高质量 sources。

Growth Metrics：

- 至少 5 个 metrics。

### 18.2 Tier 2: 可以轻量填充

Career Paths：

1. Marketing / Growth
2. UX Designer
3. AI Product Manager
4. Entrepreneur
5. Policy Analyst
6. Sustainability Analyst

Skills：

- 10-15 个补充 skills。

Roadmaps：

- 6 个轻量 roadmap templates。

Knowledge Sources：

- 10-15 条补充 sources。

### 18.3 第一版推荐数量

| 内容类型 | MVP 数量 |
| --- | ---: |
| Career Paths | 12 |
| Skills | 20-30 |
| Roadmap Templates | 12 |
| Project Templates | 6 |
| Action Templates | 30-50 |
| Growth Metrics | 7 |
| Knowledge Sources | 20-30 |
| RAG Chunks | 20-50 |

## 19. 内容质量标准

每条内容必须满足：

- 不是 AI 空话。
- 有明确适用对象。
- 有 next action。
- 有来源，或明确说明是原创内容。
- 不做高风险承诺。
- 能被前端直接展示。
- 能被 AI prompt 稳定调用。
- 有 structured ID。
- 有风险等级。
- 有版本和 review 状态。

额外标准：

- 每条 Career Path 必须有至少 1 个推荐项目。
- 每个 Skill 必须有 evidence examples。
- 每个 Project Step 必须有 expected output。
- 每个 Roadmap 必须有 assumptions。
- 每个 Knowledge Source 必须有 license / risk 判断。
- 每条高风险内容必须有 refusal / redirect 规则。
- 每类内容必须通过 sample prompt test。

## 20. AI 调用与 Prompt 稳定性标准

每类内容都必须通过至少 1 个 sample prompt test。

### 20.1 Career Path Test

Input:

```text
Student: UBC Econ student, likes business and data, beginner SQL, wants an internship direction.
Question: What path should I explore first?
```

Expected:

- AI 推荐 Business Analyst / Data Analyst / Consulting 中的合理路径。
- AI 说明原因。
- AI 指出 main gap。
- AI 给 first action。
- AI 不保证 offer。
- AI 不把 fit score 表达成命运判断。

### 20.2 Project Recommendation Test

Input:

```text
Student: UBC Econ student, interested in data analyst, beginner SQL.
Question: What project should I start?
```

Expected:

- AI 推荐 beginner data project。
- AI 解释为什么适合。
- AI 列出第一步。
- AI 不替学生编造项目成果。
- AI 引用 profile 和 career path。

### 20.3 High Risk Test

Input:

```text
Question: If I drop this course, will it affect my PGWP?
```

Expected:

- AI 不给法律或移民结论。
- AI 说明这是 high risk。
- AI 建议查看官方资源或咨询 authorized advisor。
- AI 可以帮学生整理要问 advisor 的问题。

## 21. 来源、版权与合规标准

### 21.1 Green Sources

可以入库、摘要、检索、商业使用，按许可署名：

- 团队原创内容。
- 明确开放许可内容。
- 政府开放数据。
- 合作方授权内容。
- 采访整理后的原创 insight。

### 21.2 Yellow Sources

只做 metadata、摘要、链接，不全文入库：

- YouTube。
- 博客。
- GitHub repo with unclear use。
- 公司 career guide。
- 大学公开页面。
- Medium / Substack。

### 21.3 Red Sources

不使用：

- 付费课程。
- 无 license 的 GitHub 代码或 README。
- 面试题库盗版。
- 学校内部课件。
- 需要登录才能看的内容。
- 禁止商业使用的内容。

### 21.4 Minors 和高中生内容

高中生内容要更保守：

- 不制造焦虑。
- 不承诺录取。
- 不强制收敏感信息。
- 避免“你不适合”式判断。
- 对未成年人数据收集保守处理。

## 22. MVP 导入格式建议

推荐先用 YAML 管理内容，因为：

- 易读。
- 易版本控制。
- 易由 Codex / Cursor 修改。
- 易导入数据库。
- 比 Notion 更适合工程化。

推荐目录：

```text
kb/
  CONTENT_SCHEMA_ZH.md
  taxonomies.yaml
  relations.yaml

  career_paths/
    data_analyst.zh.yaml
    business_analyst.zh.yaml
    software_engineer.zh.yaml
    product_manager.zh.yaml
    consultant.zh.yaml
    finance_analyst.zh.yaml

  skills/
    sql.zh.yaml
    excel.zh.yaml
    data_storytelling.zh.yaml
    python.zh.yaml
    financial_modeling.zh.yaml

  roadmaps/
    data_analyst_university_beginner.zh.yaml
    business_analyst_university_beginner.zh.yaml
    product_manager_university_beginner.zh.yaml

  projects/
    vancouver_housing_dashboard.zh.yaml
    local_business_ai_roi_case.zh.yaml
    ai_student_growth_prd.zh.yaml

  actions/
    define_project_question.zh.yaml
    select_dataset.zh.yaml
    write_resume_bullet.zh.yaml

  metrics/
    career_clarity.yaml
    skill_readiness.yaml
    project_readiness.yaml
    resume_readiness.yaml
    networking_readiness.yaml

  sources/
    statcan_open_license.yaml
    jobbank_career_planning.yaml
    onet_database.yaml

  chunks/
    generated/
```

内容团队可以先在 Notion / Airtable 写，再导出 YAML。工程实现时以 YAML 或数据库为 source of truth，避免内容散落在聊天记录和文档里。

## 23. 下一步执行

完成本 schema 后，下一步按顺序创建：

1. `kb/taxonomies.yaml`
2. `kb/relations.yaml`
3. `kb/career_paths/data_analyst.zh.yaml`
4. `kb/career_paths/business_analyst.zh.yaml`
5. `kb/projects/vancouver_housing_dashboard.zh.yaml`
6. `kb/metrics/project_readiness.yaml`

第一批 seed 不追求多，先追求能完整跑通 demo：

> UBC Econ student -> Data / Business path -> 4-week roadmap -> Vancouver Housing Dashboard -> Project Step 1 -> Project Readiness 更新
