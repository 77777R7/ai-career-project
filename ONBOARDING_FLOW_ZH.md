# ONBOARDING_FLOW_ZH

日期：2026-06-26

## 1. 文档目的

本文件定义 AI Student Growth Platform 第一版 MVP 的 onboarding flow。

它承接：

- `ICP_AND_USER_STORIES_ZH.md`
- `CAREER_MATCHER_RULES_ZH.md`
- `DATA_SCHEMA_ZH.md`
- `DEMO_SCRIPT_ZH.md`

核心目标：

> 用尽量少的问题收集足够信号，让用户快速进入 Career Match，而不是把 onboarding 做成长问卷。

第一版 onboarding 要服务完整闭环：

```text
Onboarding -> Profile Summary -> Career Match -> Roadmap -> Project Builder -> Dashboard -> AI Advisor
```

## 2. Onboarding 的产品原则

### 2.1 第一价值不是“填完整资料”

用户来这里不是为了建立一份完美档案，而是为了知道：

- 我现在有哪些方向值得先探索？
- 我为什么适合先看这些方向？
- 我现在最大的 gap 是什么？
- 我这周可以做什么？

因此，onboarding 只问能直接提升第一轮 Career Match 质量的问题。

### 2.2 先完成薄 profile，再渐进补全

Profile 分三层：

| 层级 | 作用 | 收集时机 |
| --- | --- | --- |
| Required Profile | 让 matcher 可以运行 | 首次 onboarding |
| Recommended Profile | 让推荐更具体 | 首次 onboarding 中可选或轻量收集 |
| Progressive Profile | 让 roadmap、project、advisor 更准 | 用户进入后续模块时补问 |

第一版不要一次性问完整 `student_profiles` 表里的所有字段。

### 2.3 不按年级硬限制

产品支持：

- 高中生。
- 大学生。
- 新毕业生。
- early-career explorers。
- undecided users。

`grade_level` 不是必填字段。高中生可以使用，但不需要被限制为某个具体年级。

### 2.4 全国加拿大范围

产品不局限 BC / Vancouver。

Onboarding 可以问 `province`，但它不是硬门槛。MVP 默认 `country: Canada`，`province` 可以是：

```yaml
BC
ON
AB
QC
other
not_sure
prefer_not_to_say
```

Demo 可以使用 Vancouver 项目样例，但产品边界是全加拿大。

### 2.5 允许 undecided 是正常状态

用户不确定专业、职业、技能和项目方向时，不应该被卡住。

Onboarding 文案要让用户知道：

> 不确定也可以继续。系统会根据你已有的信息给出探索路线，而不是要求你先想清楚。

### 2.6 AI 只辅助总结，不替代状态

Onboarding 可以用 AI 生成 profile summary，但结构化字段必须写入 `student_profiles`。

不能只保存一段自由文本，然后让 AI 每次重新猜用户状态。

## 3. MVP Onboarding 完成标准

用户完成 MVP onboarding 后，系统至少要能写入：

```yaml
completed_profile: true
student_type:
student_stage:
country: Canada
main_question:
liked_subjects:
interested_industries:
skills:
projects:
internships:
weekly_time_commitment_hours:
```

其中 Career Matcher 真正 required 的字段是：

```yaml
student_type:
student_stage:
country:
main_question:
```

如果 recommended fields 缺失，matcher 仍然可以运行，但必须在 `uncertainty` 里说明推荐不确定性。

## 4. Onboarding Flow 总览

MVP 推荐使用 4 个短步骤加 1 个确认页：

```text
Step 0: Consent / Demo Entry
Step 1: Current Situation
Step 2: Direction Signal
Step 3: Skills and Evidence
Step 4: Time and Goal
Step 5: Profile Summary Confirmation
```

建议完成时间：

```yaml
fast_path: 3-5 minutes
normal_path: 5-8 minutes
max_without_user_fatigue: 10 minutes
```

不要把 onboarding 做到 15 分钟以上。15 分钟应该是从 onboarding 到看到 Career Match 结果的总时间。

## 5. Step 0: Consent / Demo Entry

### 5.1 目的

在不制造登录摩擦的前提下，建立最基本的数据和隐私边界。

### 5.2 用户看到

用户可以选择：

```text
Start demo
Create account
Sign in
```

第一版建议支持 demo mode：

- Demo user 可以不登录先跑完整体验。
- 保存长期进度时再引导创建账号。
- 如果正式上线涉及未成年人和真实账号，需要增加法律审查后的 consent flow。

### 5.3 写入数据

```yaml
user_accounts:
  account_type: demo | student
  country: Canada
  locale:
  status: active

consent_records:
  consent_type: privacy_policy
  policy_version:
  accepted:
  source: signup | onboarding
```

### 5.4 不要问

Step 0 不要问：

- 精确生日。
- 家庭收入。
- 家长信息。
- 详细地址。
- 政府 ID。
- 成绩单。
- resume 上传。

## 6. Step 1: Current Situation

### 6.1 目的

判断用户当前处于什么规划阶段，并生成 `student_type` / `student_stage`。

### 6.2 用户问题

```text
Which best describes you right now?
```

### 6.3 推荐控件

使用 segmented cards 或 radio list。

选项：

```yaml
- I am in high school
- I am in university or college
- I recently graduated
- I am early in my career and exploring a new direction
- I am not sure
```

### 6.4 字段映射

| 用户选择 | student_type | student_stage |
| --- | --- | --- |
| I am in high school | `high_school_student` | `high_school_explorer` |
| I am in university or college | `university_student` | `university_beginner` 默认，后续可细分 |
| I recently graduated | `recent_graduate` | `recent_graduate` |
| I am early in my career | `early_career` | `early_career` |
| I am not sure | `unknown` | `explorer_unknown` |

### 6.5 Conditional follow-up

如果用户选择 university / college：

```text
What is your current or intended major?
```

字段：

```yaml
major:
target_majors:
```

推荐选项先覆盖：

```yaml
- Economics
- Commerce
- Business
- Statistics
- Computer Science
- Data Science
- Cognitive Systems
- International Relations
- Undecided
- Other
```

如果用户选择 high school：

```text
What subjects or university areas are you considering?
```

字段：

```yaml
target_majors:
```

不要问具体年级作为必填。

### 6.6 Optional location

问题：

```text
Where in Canada are you mainly studying or planning?
```

字段：

```yaml
country: Canada
province:
```

选项：

```yaml
- BC
- Ontario
- Alberta
- Quebec
- Other province or territory
- Not sure yet
- Prefer not to say
```

### 6.7 不要问

此步骤不要问：

- 学校排名。
- GPA。
- 详细课程成绩。
- 年级作为硬性门槛。
- 移民身份。

## 7. Step 2: Direction Signal

### 7.1 目的

收集兴趣、方向和用户当前问题，帮助 Career Matcher 排序。

### 7.2 核心问题 1

```text
What are you trying to figure out right now?
```

字段：

```yaml
main_question:
```

推荐选项：

```yaml
- I do not know which career path to explore.
- I am choosing between majors or programs.
- I need a project idea for my resume or portfolio.
- I want to prepare for internships but do not know where to start.
- I want to understand how my interests connect to careers.
- Other
```

允许用户补充自由文本。

### 7.3 核心问题 2

```text
Which areas sound interesting to you?
```

字段：

```yaml
interested_industries:
liked_subjects:
```

推荐选项：

```yaml
- Business
- Economics
- Data
- Technology
- Consulting
- Finance
- Policy
- International relations
- Research
- Product
- Design
- Marketing / growth
- Not sure yet
```

### 7.4 核心问题 3

```text
What do you usually enjoy doing?
```

字段：

```yaml
preferred_work_styles:
```

推荐选项：

```yaml
- Analyzing information
- Explaining ideas
- Building things
- Solving business problems
- Working with data
- Writing or presenting
- Researching social or policy issues
- Organizing people or projects
- Not sure yet
```

### 7.5 可选反向信号

问题：

```text
Anything you know you do not want right now?
```

字段：

```yaml
disliked_subjects:
```

推荐选项：

```yaml
- Heavy coding
- Heavy math
- Pure sales
- Too much writing
- Too much presentation
- Repetitive tasks
- Not sure
```

### 7.6 V1 备注

`disliked_subjects` 是 support signal，不是排除规则。

例如用户选择 `Heavy coding`，系统不应该说“不适合 data”。更好的表达是：

```text
Data Analyst may still be worth testing, but the first project should start with spreadsheets and visualization before SQL or Python.
```

## 8. Step 3: Skills and Evidence

### 8.1 目的

判断用户现在有什么能力证据，以及 first project 应该从哪里开始。

### 8.2 核心问题 1

```text
What have you used before?
```

字段：

```yaml
skills:
```

V1 技能选项：

```yaml
excel:
sql:
python:
presentation:
writing:
research:
statistics:
business_analysis:
```

每个技能 level：

```yaml
none
beginner
intermediate
advanced
proven_by_project
```

### 8.3 推荐 UI

不要做成 8 个长下拉框。

建议 UI：

```text
Skill row + quick level chips
```

例如：

```text
Excel: None / Beginner / Intermediate / Strong
SQL: None / Beginner / Intermediate / Strong
Python: None / Beginner / Intermediate / Strong
Presentation: None / Beginner / Intermediate / Strong
```

### 8.4 核心问题 2

```text
Do you already have any projects, internships, or activities you want the system to consider?
```

字段：

```yaml
projects:
internships:
extracurriculars:
```

推荐选项：

```yaml
- No, not yet
- I have a school project
- I have a personal project
- I have an internship or work experience
- I have club or extracurricular experience
- I am not sure what counts
```

### 8.5 轻量输入

如果用户选择有经历，只问一句：

```text
Briefly describe one experience.
```

不要在 onboarding 阶段要求填写：

- 公司名。
- supervisor。
- 详细日期。
- 完整 bullet points。
- 文件上传。

### 8.6 写入示例

```yaml
skills:
  excel: beginner
  sql: none
  python: none
  presentation: beginner
  writing: intermediate
projects: []
internships: []
extracurriculars: []
```

## 9. Step 4: Time and Goal

### 9.1 目的

让 Roadmap 和 Project Builder 知道任务难度和节奏。

### 9.2 核心问题 1

```text
How much time can you realistically spend each week?
```

字段：

```yaml
weekly_time_commitment_hours:
```

选项：

```yaml
- Less than 2 hours
- 2-4 hours
- 5-7 hours
- 8-10 hours
- More than 10 hours
- Not sure
```

存储时可以转为 number range 或 midpoint：

| 选项 | 存储建议 |
| --- | --- |
| Less than 2 hours | `1` |
| 2-4 hours | `3` |
| 5-7 hours | `5` |
| 8-10 hours | `8` |
| More than 10 hours | `10` |
| Not sure | `null` |

### 9.3 核心问题 2

```text
What would feel useful by the end of the next 4 weeks?
```

字段：

```yaml
short_term_goal:
```

选项：

```yaml
- Pick one career path to explore first
- Understand 2-3 possible paths
- Start a portfolio project
- Finish the first project milestone
- Know what skills to learn next
- Prepare for internship search
- Other
```

### 9.4 Optional long-term goal

问题：

```text
Longer term, what are you hoping this helps with?
```

字段：

```yaml
long_term_goal:
```

这个字段建议可跳过。

## 10. Step 5: Profile Summary Confirmation

### 10.1 目的

让用户确认系统理解正确，同时生成进入 Career Match 的心理承接。

### 10.2 用户看到

系统生成一段短 summary：

```text
You are a Canadian university Economics student exploring business, data, and consulting-related paths. You enjoy economics, business, and market analysis, and you currently have beginner Excel and presentation skills. You do not have a portfolio project yet, and you can spend about 5 hours per week. Your main goal is to find a clearer direction and start building evidence.
```

### 10.3 用户操作

按钮：

```text
Looks right
Edit
Show my career matches
```

### 10.4 写入数据

```yaml
student_profiles:
  completed_profile: true
  profile_summary:
  profile_summary_version:

profile_events:
  event_type: summary_generated

audit_logs:
  action: profile_summary_generated
```

### 10.5 验收标准

Profile Summary 必须：

- 引用用户真实输入。
- 说清当前阶段。
- 说清兴趣方向。
- 说清已有技能或经历。
- 说清当前 gap。
- 不评判用户。
- 不承诺结果。
- 不用焦虑或羞辱语言。

## 11. Field Priority Matrix

### 11.1 首次 onboarding 必问

| 字段 | 原因 |
| --- | --- |
| `student_type` | 判断用户阶段 |
| `student_stage` | 调整推荐语气和 action 难度 |
| `country` | MVP 国家范围 |
| `main_question` | 判断用户当前核心任务 |

### 11.2 首次 onboarding 强烈建议问

| 字段 | 原因 |
| --- | --- |
| `major` / `target_majors` | 连接专业和 path |
| `liked_subjects` | 提升 interest score |
| `interested_industries` | 提升 path ranking |
| `preferred_work_styles` | 区分 data / business / consulting / policy |
| `skills` | 判断 skill gap |
| `projects` | 判断 evidence gap |
| `internships` | 判断 evidence gap |
| `weekly_time_commitment_hours` | 决定 roadmap 难度 |
| `short_term_goal` | 决定 first action |

### 11.3 首次 onboarding 可选

| 字段 | 原因 |
| --- | --- |
| `province` | 个性化加拿大语境，但不是硬门槛 |
| `school` | 可以帮助表达具体，但不应影响可用性 |
| `disliked_subjects` | 调整支持策略 |
| `extracurriculars` | 增加 evidence signal |
| `long_term_goal` | 用于 Advisor 和 roadmap |

### 11.4 不在首次 onboarding 问

| 字段 | 原因 | 后续时机 |
| --- | --- | --- |
| `grade_level` | 不按年级限制 | 高中用户需要更细规划时 |
| `resume_text_optional` | 隐私和摩擦高 | 用户进入求职准备时 |
| `linkedin_text_optional` | 隐私和摩擦高 | 用户主动请求 profile review 时 |
| `GPA` | 敏感且容易制造焦虑 | V1 不问 |
| `transcript` | 文件隐私和解析复杂 | V1 不问 |
| `immigration_status` | 法律风险和敏感 | V1 不问 |
| `family_income` | 敏感且不服务 MVP | V1 不问 |

## 12. Progressive Profile Strategy

### 12.1 Career Match 后补问

触发条件：

- match uncertainty 高。
- top 3 path 分数接近。
- 用户点击“why these paths?”。

可以补问：

```yaml
preferred_work_styles:
disliked_subjects:
target_majors:
extracurriculars:
```

示例问题：

```text
To make this comparison more specific, which type of work sounds more energizing right now?
```

### 12.2 Roadmap 生成前补问

触发条件：

- `weekly_time_commitment_hours` 缺失。
- 用户保存 primary path 后需要生成计划。

可以补问：

```yaml
weekly_time_commitment_hours:
short_term_goal:
preferred_project_pace:
```

示例问题：

```text
Before I build your 4-week plan, how much time should the plan assume each week?
```

### 12.3 Project Builder 内补问

触发条件：

- 用户开始项目。
- 系统需要决定 project difficulty 或 first step。

可以补问：

```yaml
skills:
projects:
preferred_output_type:
dataset_preference:
```

示例问题：

```text
For this project, would you rather start with a spreadsheet, a dashboard, or a short written analysis?
```

### 12.4 Dashboard 内补问

触发条件：

- 某个 metric 缺少 evidence。
- 用户希望提升 score。

可以补问：

```yaml
self_assessed_confidence:
completed_actions:
reflection_notes:
```

示例问题：

```text
What changed after completing this task?
```

### 12.5 AI Advisor 触发补问

Advisor 不应该一次性索要完整 profile。它只在回答需要时补一个最小问题。

| 用户问题 | Advisor 可补问字段 |
| --- | --- |
| “我应该选什么专业？” | `target_majors`, `liked_subjects`, `disliked_subjects` |
| “我应该做什么项目？” | `skills`, `projects`, `weekly_time_commitment_hours` |
| “Data Analyst 和 Business Analyst 哪个更适合？” | `preferred_work_styles`, `skills`, `main_question` |
| “我怎么准备实习？” | `projects`, `internships`, `short_term_goal` |
| “我完全不知道方向” | `liked_subjects`, `interested_industries`, `preferred_work_styles` |

### 12.6 Advisor 补问写入规则

Advisor 提出的补问不应该自动改 profile。

流程应该是：

```text
Advisor asks one clarifying question
User answers
System shows proposed profile update
User confirms
student_profiles updated
profile_events inserted
audit_logs inserted
```

## 13. Conditional Branches

### 13.1 High School Explorer

目标：

- 帮用户连接兴趣、大学专业和职业方向。
- 表达为 exploration，不表达为就业承诺。

必问：

```yaml
student_type: high_school_student
student_stage: high_school_explorer
target_majors:
liked_subjects:
main_question:
```

避免：

- 不要求具体年级。
- 不暗示必须现在决定人生路径。
- 不承诺大学录取。
- 不做家长 dashboard。

推荐 summary 语气：

```text
You are exploring how your interests could connect to future university programs and career paths.
```

### 13.2 University Explorer

目标：

- 帮用户从专业、兴趣、技能和项目缺口进入 career path comparison。

必问：

```yaml
student_type: university_student
student_stage:
major:
liked_subjects:
interested_industries:
skills:
main_question:
```

推荐 summary 语气：

```text
You are trying to turn your current academic direction into a clearer career exploration plan.
```

### 13.3 Recent Graduate

目标：

- 帮用户把已有学习经历转成项目、能力证据和求职方向。

额外建议问：

```yaml
projects:
internships:
short_term_goal:
```

避免：

- 不把产品变成纯 job board。
- 不做自动投递。
- 不承诺 offer。

### 13.4 Early Career Explorer

目标：

- 帮用户判断是否探索新方向，以及第一步如何低风险验证。

额外建议问：

```yaml
current_role_optional:
transferable_skills:
weekly_time_commitment_hours:
```

注意：

`current_role_optional` 和 `transferable_skills` 可以先放进 `projects` / `extracurriculars` 或 future profile extension，不必立刻改 schema。

## 14. Demo Persona Mapping

### 14.1 Demo User A: University Explorer

Onboarding 应收集：

```yaml
student_type: university_student
student_stage: university_beginner
country: Canada
province: all
major: Economics
liked_subjects:
  - economics
  - business
  - market analysis
disliked_subjects:
  - pure coding
interested_industries:
  - data
  - business
  - consulting
skills:
  excel: beginner
  sql: none
  python: none
  presentation: beginner
  writing: intermediate
projects: []
internships: []
short_term_goal: Find a clearer internship direction before second year.
long_term_goal: Work in a business or data-related role.
weekly_time_commitment_hours: 5
main_question: I do not know whether I should explore data analyst, business analyst, or consulting.
```

成功后进入：

```yaml
career_match:
  - career_path.business_analyst
  - career_path.data_analyst
  - career_path.consultant
```

### 14.2 Demo User B: High School Explorer

Onboarding 应收集：

```yaml
student_type: high_school_student
student_stage: high_school_explorer
country: Canada
province: all
target_majors:
  - Business
  - Economics
  - Data Science
  - International Relations
liked_subjects:
  - economics
  - social studies
  - data
interested_industries:
  - business
  - policy
  - data
skills:
  spreadsheet_basics: beginner
  presentation: beginner
  writing: intermediate
projects: []
internships: []
short_term_goal: Understand which university and career directions are worth exploring first.
weekly_time_commitment_hours: 3
main_question: I am not sure what major or career direction fits my interests.
```

成功后进入：

```yaml
career_match:
  language: exploration
  no_employment_guarantee: true
```

## 15. Data Write Contract

### 15.1 On submit

用户完成 onboarding 后：

```text
upsert user_accounts
insert consent_records if needed
upsert student_profiles
insert profile_events
insert audit_logs
generate profile_summary
insert profile_events: summary_generated
```

### 15.2 student_profiles 最小 payload

```yaml
completed_profile: true
student_type:
student_stage:
country: Canada
province:
major:
target_majors:
liked_subjects:
disliked_subjects:
interested_industries:
preferred_work_styles:
skills:
projects:
internships:
extracurriculars:
short_term_goal:
long_term_goal:
main_question:
weekly_time_commitment_hours:
profile_summary:
profile_summary_version:
data_quality_flags:
```

### 15.3 data_quality_flags

缺失 recommended 字段时，不阻止用户继续。

示例：

```yaml
data_quality_flags:
  missing_recommended_fields:
    - preferred_work_styles
    - extracurriculars
  uncertainty_level: medium
  next_best_profile_question: What type of work sounds more energizing to you right now?
```

## 16. Onboarding UX Rules

### 16.1 控件建议

| 信息类型 | 推荐控件 |
| --- | --- |
| 单选阶段 | Segmented cards / radio cards |
| 多选兴趣 | Chips |
| 技能等级 | Row + level chips |
| 每周时间 | Segmented control |
| 自由问题 | Short textarea |
| 可选字段 | Collapsible / later prompt |

### 16.2 文案规则

应该使用：

```text
Not sure yet
Skip for now
You can change this later
This helps us make your first plan more specific
```

避免使用：

```text
Required for accurate results
You must decide now
This determines your best career
You are not suitable for
```

### 16.3 页面节奏

每个 screen 最多：

- 1 个主问题。
- 1 个可选 follow-up。
- 1 个自由文本入口。

不要在一个 screen 上同时问：

- 专业。
- 兴趣。
- 技能。
- 项目。
- 每周时间。
- 长期目标。

### 16.4 空状态处理

用户选择 `Not sure yet` 时，系统应该继续。

示例：

```yaml
liked_subjects: []
interested_industries:
  - not_sure_yet
data_quality_flags:
  uncertainty_level: medium
```

## 17. Safety and Privacy Rules

### 17.1 Minors

高中用户可能是未成年人。MVP 文档层面先保留：

```yaml
age_band:
guardian_or_parental_consent:
```

但第一版 demo 不需要强制实现完整家长同意流程。

正式上线前必须根据地区和法律审查决定：

- 是否收集 age band。
- 是否需要 guardian consent。
- 哪些数据不可收集。
- 数据保留和删除规则。

### 17.2 Sensitive topics

Onboarding 不问：

- 移民身份。
- 医疗或心理状态。
- 家庭收入。
- 精确地址。
- 政府 ID。
- 完整成绩单。

如果用户主动提到高风险话题，系统只做边界说明和资源导航，不做专业结论。

### 17.3 Consent

需要明确同意的功能：

```yaml
profile_personalization
ai_advisor
user_uploaded_files
marketing_communications
guardian_or_parental_consent
```

第一版 onboarding 至少应有：

```yaml
privacy_policy
profile_personalization
```

## 18. Acceptance Criteria

Onboarding 通过标准：

- 用户能在 5-8 分钟内完成。
- 用户可以选择 `Not sure yet` 并继续。
- 高中生不需要填写具体年级。
- 非 BC / Vancouver 用户不会被排除。
- 用户不需要上传 resume、成绩单或 LinkedIn。
- 系统能生成 profile summary。
- 系统能写入 `student_profiles`。
- 系统能触发 Career Matcher。
- Career Matcher 至少能返回 3 个 path。
- 缺失推荐字段时，系统显示 uncertainty，而不是阻止结果。
- 文案不制造焦虑、不承诺结果、不判断用户人生路径。

## 19. Implementation Notes

### 19.1 V1 UI route suggestion

```text
/onboarding
/profile/summary
/career-match
```

### 19.2 V1 API usage

Onboarding submit:

```text
POST /api/profile
```

Profile summary:

```text
POST /api/profile/summary
```

Career match:

```text
POST /api/career-matches
```

### 19.3 First prototype shortcut

如果先做 clickable prototype，可以先把 onboarding 数据存在 local mock state：

```yaml
mock_user_account:
mock_student_profile:
mock_profile_summary:
```

但字段名应该和 `DATA_SCHEMA_ZH.md` 保持一致，避免后面接数据库时重写。

## 20. Next Recommended Step

完成 onboarding flow 后，下一步建议做：

> `APP_DATA_MODEL_SQL_DRAFT.sql`

原因：

- KB schema 已经有。
- Seed content 已经有。
- ICP 和 demo 已经有。
- Career Matcher 规则已经有。
- Runtime data schema 已经有。
- Onboarding flow 已经把首批 profile 字段拆好了。

下一步可以把 `DATA_SCHEMA_ZH.md` 转成第一版 Supabase / Postgres SQL draft，为真正开始写前端和 API 做准备。
