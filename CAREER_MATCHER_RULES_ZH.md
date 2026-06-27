# Career Matcher V1 规则

日期：2026-06-26

## 1. 文档目的

本文件定义 Career Path Matcher V1 的输入、打分逻辑、输出结构、风险表达和测试标准。

Career Matcher 的目标不是判断一个学生“适不适合某职业”，而是给出一个当前阶段的规划信号：

> Based on your current profile, here are 3 paths worth exploring first, why they may fit, what the main gap is, and what first action can test the direction.

V1 不做机器学习模型。V1 使用：

1. 规则打分。
2. `kb/relations.yaml` 权重。
3. Career Path seed 内容。
4. LLM 解释润色和 uncertainty 表达。

核心原则：

- Fit score 是 planning signal，不是命运判断。
- 推荐结果必须可解释。
- 推荐结果必须导向 next action。
- 不按年级硬限制用户。
- 不说 “you are not fit”。
- 不承诺 offer、录取、薪资或人生最优路径。

## 2. Career Matcher 在产品中的位置

Career Matcher 位于：

```text
Student Profile -> Career Path Matcher -> Roadmap -> Project Builder -> Dashboard -> AI Advisor
```

它读取：

- Student Profile
- KB Career Paths
- KB Skills
- `kb/relations.yaml`
- Project recommendations
- Risk rules

它输出：

- Top 3 recommended paths
- fit_score
- fit_reason
- main_gap
- first_action
- recommended_project_id
- uncertainty
- risk_notes

## 3. 支持用户范围

Career Matcher 不按年级限制使用。

支持用户：

- 高中生。
- 大学生。
- 新毕业生。
- early-career explorers。
- 国际学生。
- undecided users。

只要用户有专业/职业规划、项目积累、方向探索或长期成长需求，就可以进入 matcher。

第一版内容方向先聚焦：

- Economics
- Commerce
- Business
- Statistics
- CS
- Data Science
- Cognitive Systems
- International Relations
- undecided

第一版推荐路径先以 KB 已有 path 为准：

- `career_path.business_analyst`
- `career_path.data_analyst`
- `career_path.consultant`

后续应补：

- Software Engineer
- Product Manager
- Finance Analyst
- Policy Analyst
- AI Product Manager
- Marketing / Growth
- UX Designer
- Sustainability Analyst

## 4. 输入字段

### 4.1 Required inputs

```yaml
student_type:
student_stage:
country:
main_question:
```

如果 required inputs 缺失，matcher 仍可运行，但必须返回 uncertainty，并提示用户补充信息。

### 4.2 Recommended inputs

```yaml
school:
province:
grade_level:
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
weekly_time_commitment_hours:
resume_text_optional:
linkedin_text_optional:
```

### 4.3 输入字段说明

| 字段 | 用途 |
| --- | --- |
| `student_type` | 区分 high_school_student、university_student、recent_graduate、early_career |
| `student_stage` | 用于调整表达和 action 难度，不用于硬性排除 |
| `major` / `target_majors` | 专业/目标专业和 career path 的关系 |
| `liked_subjects` | 兴趣匹配 |
| `disliked_subjects` | challenge / support strategy，不用于否定 |
| `interested_industries` | 兴趣匹配和推荐解释 |
| `preferred_work_styles` | 如 analysis、people、coding、writing、design、research |
| `skills` | 当前技能匹配和 gap |
| `projects` | 项目/经历匹配 |
| `internships` | 经历匹配 |
| `weekly_time_commitment_hours` | 推荐 action 的难度和节奏 |
| `main_question` | 用户当前最想解决的问题 |

## 5. Profile normalization

V1 先把用户输入规范化成 matcher-friendly profile。

### 5.1 Student stage normalization

```yaml
high_school_student -> high_school_explorer
university_student with year 1-2 -> university_beginner
university_student with year 3-4 -> university_mid or university_job_search
recent_graduate -> recent_graduate
early_career -> early_career
unknown -> explorer_unknown
```

注意：

- `high_school_explorer` 不代表固定年级。
- `university_beginner` 是体验阶段，不是硬年级。
- stage 用于推荐语气和 action 难度，不用于拒绝用户。

### 5.2 Skill level normalization

```yaml
none: 0.0
beginner: 0.3
intermediate: 0.6
advanced: 0.9
proven_by_project: 1.0
unknown: null
```

缺失 skill 不等于 0。只有用户明确说 `none` 才记 0。

### 5.3 Interest keyword normalization

示例映射：

```yaml
economics:
  - economics
  - market analysis
  - policy
  - business
business:
  - commerce
  - business
  - operations
  - strategy
data:
  - data
  - statistics
  - analytics
  - dashboards
coding:
  - coding
  - programming
  - software
writing:
  - writing
  - communication
  - social studies
people:
  - presentation
  - teamwork
  - leadership
```

V1 可以先用 simple keyword map。不要过早做 embeddings。

## 6. Candidate path generation

V1 candidate paths 来自 KB：

1. 读取 `kb/career_paths/*.yaml`。
2. 过滤 `status: active`。
3. 过滤 `visibility: student_visible` 或 `public`。
4. 保留 `risk_level: low` 和 `medium` 的职业路径。
5. 不因为 student_stage 不匹配而直接剔除，只降低 confidence 或调整 action。

每个 candidate path 关联：

- `related_majors`
- `best_fit_for`
- `common_challenges`
- `required_skills`
- `first_project_recommendation`
- `career_path_skills` from `kb/relations.yaml`
- `career_path_projects` from `kb/relations.yaml`

## 7. 打分总览

V1 总分 100。

| 维度 | 权重 |
| --- | ---: |
| Interest Fit | 25 |
| Skill Fit | 20 |
| Major / Academic Fit | 15 |
| Evidence Fit | 15 |
| Goal Fit | 15 |
| Time / Execution Fit | 10 |

输出 `fit_score` 时四舍五入为整数。

同时输出：

```yaml
score_breakdown:
  interest_fit:
  skill_fit:
  academic_fit:
  evidence_fit:
  goal_fit:
  time_fit:
```

前端可以先不展示 breakdown，但内部必须保留，方便 debug。

## 8. Interest Fit 规则

权重：25。

### 8.1 输入

- `liked_subjects`
- `interested_industries`
- `preferred_work_styles`
- `main_question`
- `disliked_subjects`

### 8.2 正向匹配

匹配来源：

- path `summary`
- path `best_fit_for`
- path `tags`
- path `daily_tasks`
- path `related_majors`

示例：

```yaml
data_analyst:
  positive_keywords:
    - data
    - analytics
    - statistics
    - economics
    - market analysis
    - dashboards

business_analyst:
  positive_keywords:
    - business
    - commerce
    - operations
    - problem-solving
    - communication
    - analysis

consultant:
  positive_keywords:
    - consulting
    - strategy
    - business
    - communication
    - problem-solving
    - presentation
```

### 8.3 反向信号

反向信号不用于否定用户，只用于说明 challenge。

例子：

- 用户不喜欢 pure coding：降低 Software-heavy paths，Data Analyst 不直接剔除，但标记 SQL/dashboard 是 testable gap。
- 用户不喜欢 presentation：Consulting 降分，并把 communication practice 作为 challenge。
- 用户不喜欢 math/statistics：Data Analyst 降分，并建议先做 small project test。

### 8.4 评分

建议：

```text
strong match: 21-25
moderate match: 14-20
weak match: 7-13
insufficient data: 10-15 with uncertainty
clear mismatch: 0-6, but avoid harsh wording
```

## 9. Skill Fit 规则

权重：20。

### 9.1 输入

- student `skills`
- path `required_skills`
- `career_path_skills` in `kb/relations.yaml`

### 9.2 计算方法

对每个 path：

1. 读取该 path 的 required skills。
2. 从 `career_path_skills` 读取每个 skill 的 `weight`。
3. 将用户 skill level 转成数值。
4. 加权求和。

公式：

```text
skill_fit_raw = sum(skill_level_value * relation_weight) / sum(relation_weight)
skill_fit_score = skill_fit_raw * 20
```

如果 skill 缺失：

- unknown 不等于 0。
- unknown skill 先按 0.3 计算，但加入 uncertainty。
- 用户明确说 none 才按 0。

### 9.3 Gap 输出

main_gap 优先从低分核心 skill 中生成。

例子：

```yaml
path: career_path.data_analyst
core_skills:
  - skill.sql
  - skill.data_visualization
gap_if_low:
  - SQL basics
  - dashboard building
```

## 10. Major / Academic Fit 规则

权重：15。

### 10.1 输入

- `major`
- `target_majors`
- `liked_subjects`
- path `related_majors`
- path `recommended_courses`

### 10.2 评分

```text
direct major match: 12-15
adjacent major match: 8-11
exploration match: 5-7
no data: 6-9 with uncertainty
low match: 0-4
```

### 10.3 方向聚焦

第一版对这些专业/方向识别较强：

- Economics
- Commerce
- Business
- Statistics
- CS
- Data Science
- Cognitive Systems
- International Relations
- undecided

如果用户是 undecided：

- 不惩罚。
- 更依赖 liked_subjects、interests、preferred_work_styles。
- 输出要强调 exploration path。

## 11. Evidence Fit 规则

权重：15。

### 11.1 输入

- `projects`
- `internships`
- `extracurriculars`
- portfolio / resume optional text
- path `project_ideas`
- `career_path_projects` relations

### 11.2 评分

```text
has directly relevant project/internship: 12-15
has adjacent project/extracurricular evidence: 8-11
has general school/club/volunteer evidence: 4-7
no evidence yet: 0-3
unknown: 5-7 with uncertainty
```

### 11.3 解释规则

没有 evidence 不要写成失败。

错误：

```text
You lack experience.
```

正确：

```text
Your biggest growth opportunity is project evidence. A small beginner project can test this path and give you something concrete to discuss.
```

## 12. Goal Fit 规则

权重：15。

### 12.1 输入

- `short_term_goal`
- `long_term_goal`
- `main_question`
- `student_type`
- `student_stage`

### 12.2 评分

```text
goal explicitly matches path: 12-15
goal partially matches path: 8-11
goal is exploration/general clarity: 8-12
goal points elsewhere: 0-7
missing goal: 6-8 with uncertainty
```

### 12.3 高中生/探索用户

如果用户目标是：

- understand majors
- choose a direction
- explore career options
- build a first project

这不是弱信号。它应该被视为 exploration-ready。

输出语气：

```text
This path is worth exploring first, not because it is a final decision, but because it gives you a concrete project and reflection test.
```

## 13. Time / Execution Fit 规则

权重：10。

### 13.1 输入

- `weekly_time_commitment_hours`
- path `first_project_recommendation`
- project estimated time
- roadmap assumptions

### 13.2 评分

```text
6+ hours/week: 9-10
3-5 hours/week: 7-8
1-2 hours/week: 4-6
unknown: 5-7 with uncertainty
0 or unrealistic: 0-3
```

### 13.3 输出规则

时间少不等于 path 不适合，而是 action 要变小。

例子：

```text
Because you have 1-2 hours per week, start with a 30-minute research question task before committing to a full dashboard project.
```

## 14. Final score calibration

### 14.1 Score bands

```yaml
85-100: strong current fit
70-84: promising fit to explore
55-69: exploration fit with clear gaps
40-54: possible but not first priority
0-39: weak current signal
```

### 14.2 用户可见 label

不要直接展示 harsh label。

推荐展示：

```yaml
85-100: Strong signal
70-84: Worth exploring
55-69: Test with a small project
40-54: Keep as backup
0-39: Not enough current signal
```

### 14.3 Tie-breakers

如果分数接近，按以下顺序排序：

1. More aligned with `main_question`。
2. Has feasible `first_project_recommendation`。
3. Better evidence growth opportunity。
4. Lower risk of overpromising。
5. Higher content maturity in KB。

## 15. Top 3 输出结构

Career Matcher 必须输出 3 条推荐。

```yaml
recommended_paths:
  - path_id: career_path.business_analyst
    rank: 1
    fit_score: 82
    fit_label: Worth exploring
    score_breakdown:
      interest_fit: 22
      skill_fit: 12
      academic_fit: 14
      evidence_fit: 3
      goal_fit: 14
      time_fit: 8
    fit_reason: This path matches your economics and business interest, and it lets you test business problem-solving without starting from a coding-heavy route.
    main_gap: You need stronger project evidence and clearer examples of structured analysis.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
    uncertainty:
      - No resume or project history was provided.
    risk_notes:
      - This is a planning signal, not a guarantee of internship or job outcomes.
```

## 16. first_action 规则

first_action 优先级：

1. 如果 path 有 recommended project，推荐该 project 的 Step 1 action。
2. 如果学生是 high_school_explorer，优先用 exploration / reflection action。
3. 如果用户缺 skill，推荐最小 skill action。
4. 如果用户缺 evidence，推荐 project Step 1。
5. 如果用户目标不清楚，推荐 compare paths 或 reflection action。

当前 seed 可用 action：

- `action.define_project_question`
- `action.select_dataset`

当前 seed 默认 first action：

```yaml
action_id: action.define_project_question
title: Define your project research question
```

## 17. recommended_project 规则

推荐 project 时读取：

- path `first_project_recommendation`
- `career_path_projects` in `kb/relations.yaml`
- user skill readiness
- weekly_time_commitment_hours

V1 默认：

- Data Analyst -> `project.vancouver_housing_dashboard`
- Business Analyst -> `project.vancouver_housing_dashboard`
- Consultant -> `project.vancouver_housing_dashboard` as exploration project, until consulting-specific project exists

如果用户不在 Vancouver：

- 不要把项目解释成只能服务 Vancouver 用户。
- 表达为 “a Canadian public-data dashboard project; Vancouver housing is the first template.”
- 后续可以替换成 Toronto housing、Canada grocery inflation、youth labour market、education pathway 等项目。

## 18. Missing data 处理

### 18.1 缺失数据不阻断

Matcher 可以在 profile 不完整时运行，但必须输出 uncertainty。

例子：

```yaml
uncertainty:
  - You did not provide project history, so evidence fit may be underestimated.
  - You did not provide target majors, so academic fit relies on your interests.
```

### 18.2 默认假设

```yaml
weekly_time_commitment_hours missing -> assume 3-5 hours with uncertainty
skills missing -> assume unknown, not none
projects missing -> unknown unless explicitly []
internships missing -> unknown unless explicitly []
target_majors missing -> rely on liked_subjects and main_question
```

### 18.3 补问逻辑

如果信息缺失严重，可以推荐补问，但不要阻止结果。

最多补问 3 个：

1. What subjects or activities do you enjoy most?
2. Which directions are you currently comparing?
3. How many hours per week can you spend on exploration or projects?

## 19. 风险和安全表达规则

### 19.1 禁止表达

禁止：

- You are not suitable for this career.
- This career guarantees a good job.
- You should definitely switch majors.
- You will get an internship if you follow this roadmap.
- This path is objectively best for you.
- Immigration / legal / medical / mental-health conclusions.

### 19.2 推荐表达

推荐：

- This is a planning signal based on your current profile.
- This path is worth exploring first.
- The main gap to test is...
- A low-risk next step is...
- Your profile suggests a stronger signal for...
- If this feels too technical, start with a smaller project first.

### 19.3 高风险问题

如果 main_question 涉及：

- immigration
- visa
- PGWP
- legal
- medical
- mental health
- financial investment
- guaranteed admissions/offers

Matcher 不给职业结论。返回：

```yaml
risk_level: high
needs_human_advisor: true
response_mode: official_resource_navigation
message: This question may affect legal, immigration, health, or other high-risk decisions. I can help you organize questions and find official resources, but I cannot give a conclusion.
```

## 20. LLM 使用边界

V1 中 LLM 只能做：

- 将 score breakdown 转成自然语言解释。
- 生成 safe fit_reason。
- 生成 main_gap。
- 生成 first_action wording。
- 生成 uncertainty wording。

LLM 不能做：

- 自由决定 top 3。
- 忽略 score 和 KB。
- 编造 career path。
- 编造 project completion。
- 给 high-risk 结论。
- 把 salary_note 说成承诺。

推荐流程：

```text
Rule engine scores candidates -> selects top 3 -> builds structured draft -> LLM rewrites explanation under safety rules -> validator checks JSON shape and forbidden phrases
```

## 21. Demo User A expected output

Input summary：

- University beginner。
- Economics。
- Likes business, economics, market analysis。
- Dislikes pure coding。
- Excel beginner。
- SQL none。
- No projects / internships。
- 5 hours per week。
- Wants internship direction。

Expected ranking：

1. `career_path.business_analyst`
2. `career_path.data_analyst`
3. `career_path.consultant`

Expected explanation：

- Business Analyst high because economics + business interest + moderate technical barrier。
- Data Analyst promising because economics + data/market analysis fit, but SQL/dashboard/project evidence are gaps。
- Consultant useful exploration path because business problem-solving and communication fit, but case practice/networking evidence is missing。

Expected project：

- `project.vancouver_housing_dashboard`

Expected first action：

- `action.define_project_question`

## 22. Demo User B expected output

Input summary：

- High school explorer。
- Undecided between Business, Economics, Data Science, International Relations。
- Likes social studies, economics, math, writing。
- Dislikes advanced coding。
- Beginner spreadsheet basics。
- No projects。
- 3 hours per week。
- Wants to understand major-career fit。

Expected ranking with current KB：

1. `career_path.business_analyst`
2. `career_path.data_analyst`
3. `career_path.consultant`

Expected caveat：

- Current KB does not yet include Policy Analyst or International Relations-specific paths.
- Once those paths exist, matcher should compare them for Demo User B.

Expected language：

- Use exploration language.
- Do not mention job readiness as the primary frame.
- Recommend a small public-data or reflection project to test business/data/policy interest.

## 23. 验证测试

### 23.1 YAML source test

Matcher implementation must parse:

- `kb/career_paths/*.yaml`
- `kb/skills/*.yaml`
- `kb/projects/*.yaml`
- `kb/actions/*.yaml`
- `kb/relations.yaml`

### 23.2 Reference test

All output IDs must exist in KB:

- path_id
- recommended_project_id
- action_id

### 23.3 Safety phrase test

Output must not include:

- “not suitable”
- “guarantee”
- “definitely switch”
- “will get an internship”
- “best career for you”

### 23.4 Demo test

Demo User A profile should return:

```yaml
top_3:
  - career_path.business_analyst
  - career_path.data_analyst
  - career_path.consultant
```

Demo User B profile should return the same top 3 for now, with caveat about missing policy/international relations path.

## 24. Implementation notes

### 24.1 Suggested files

When building code later:

```text
src/lib/career-matcher/load-kb.ts
src/lib/career-matcher/normalize-profile.ts
src/lib/career-matcher/score-path.ts
src/lib/career-matcher/explain-match.ts
src/lib/career-matcher/validate-output.ts
```

### 24.2 Suggested TypeScript types

```ts
type SkillLevel = "none" | "beginner" | "intermediate" | "advanced" | "proven_by_project" | "unknown";

type RecommendedPath = {
  path_id: string;
  rank: number;
  fit_score: number;
  fit_label: string;
  score_breakdown: {
    interest_fit: number;
    skill_fit: number;
    academic_fit: number;
    evidence_fit: number;
    goal_fit: number;
    time_fit: number;
  };
  fit_reason: string;
  main_gap: string;
  first_action: {
    action_id: string;
    title: string;
  };
  recommended_project_id?: string;
  uncertainty: string[];
  risk_notes: string[];
};
```

## 25. 下一步

下一步建议创建：

> `DEMO_SCRIPT_ZH.md`

原因：

- ICP 已定。
- KB seed 已有。
- Career Matcher rules 已定。
- 现在需要把 Demo User A 和 Demo User B 两个 demo 流程写成可演示脚本，之后再进入数据 schema 或代码实现。

如果直接进入代码，容易在 UI、字段和 demo story 上来回改。
