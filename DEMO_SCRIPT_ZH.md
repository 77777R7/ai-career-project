# MVP Demo Script

日期：2026-06-26

## 1. 文档目的

本文件定义第一版 MVP 的可演示脚本。

它不是 marketing pitch，也不是完整 PRD。它的作用是让团队在做 Figma、产品原型、数据库和代码时，有一个共同的演示完成线。

Demo 要证明的核心闭环：

> Profile -> Career Match -> Roadmap -> Project Builder -> Dashboard -> AI Advisor

第一版 demo 使用两个中性样例用户：

- `Demo User A: University Explorer`
- `Demo User B: High School Explorer`

这两个不是现实用户，只是演示用 persona。

## 2. Demo 总原则

### 2.1 不按年级限制

产品可服务所有有专业/职业规划需求的人：

- 高中生。
- 大学生。
- 新毕业生。
- early-career explorers。

Demo User B 是高中生样例，但不代表产品只服务某个年级。

### 2.2 不做纯 chatbot demo

Demo 入口不是聊天框。Demo 必须先展示平台结构：

1. Onboarding / Profile
2. Career Match
3. Roadmap
4. Project Builder
5. Dashboard
6. AI Advisor

AI Advisor 是最后的增强入口，不是产品主体。

### 2.3 不做大平台 demo

Demo 不展示：

- 家长端。
- 学校端。
- 雇主端。
- 自动投递。
- 完整职业库。
- 完整 RAG 抓取。
- 移民/法律/医疗/心理建议。

Demo 只展示学生从迷茫到行动的第一条路径。

## 3. Demo A: University Explorer

### 3.1 Persona

```yaml
demo_id: demo.university_explorer
label: Demo User A
student_type: university_student
student_stage: university_beginner
country: Canada
province: all
school: Canadian university
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

### 3.2 Demo A narrative

Narrator:

> This student is not ready for a pure job-search tool. They need clarity, a first project, and a weekly plan.

Product promise:

> In 10-15 minutes, the platform turns a vague career question into 3 paths, one roadmap, one beginner project, and a next action.

### 3.3 Screen 1: Profile onboarding

User sees:

- Student stage
- Current major or target major
- Interests
- Skills
- Existing projects / internships
- Main question
- Weekly time

User submits the profile above.

Expected system state:

```yaml
completed_profile: true
student_stage: university_beginner
primary_question_type: career_path_comparison
```

### 3.4 Screen 2: Profile Summary

User sees:

```text
You are a Canadian university Economics student exploring business, data, and consulting-related paths. You enjoy economics, business, and market analysis, but you do not want a pure coding-heavy path. You currently have beginner Excel and presentation skills, no SQL or Python experience, and no portfolio project or internship yet. Your short-term goal is to find a clearer internship direction before second year, with about 5 hours per week available.
```

CTA:

```text
Show my career matches
```

Acceptance criteria:

- Summary references profile facts.
- Summary does not sound like generic AI advice.
- Summary does not judge the student.

### 3.5 Screen 3: Career Match Results

Expected output:

```yaml
recommended_paths:
  - path_id: career_path.business_analyst
    rank: 1
    fit_label: Worth exploring
    fit_reason: Your Economics background, business interest, and dislike of pure coding make Business Analyst a practical first path to test.
    main_gap: You need project evidence that shows structured analysis and communication.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
  - path_id: career_path.data_analyst
    rank: 2
    fit_label: Worth exploring
    fit_reason: Your interest in economics, data, and market analysis gives this path a strong signal, but SQL and dashboard skills are current gaps.
    main_gap: SQL basics, dashboard building, and a portfolio project.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
  - path_id: career_path.consultant
    rank: 3
    fit_label: Test with a small project
    fit_reason: You show business problem-solving interest, but consulting also needs case practice, communication evidence, and networking.
    main_gap: Structured case practice and evidence of communication.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
```

Visible note:

```text
These are planning signals based on your current profile, not final career decisions.
```

CTA:

```text
Save Business Analyst as my path to test
```

Expected system state:

```yaml
compared_career_paths: 3
saved_primary_path: career_path.business_analyst
```

### 3.6 Screen 4: Roadmap

Roadmap title:

```text
Your 4-week path test
```

Roadmap content:

```yaml
week_1:
  title: Define your project question
  action_id: action.define_project_question
  expected_output: 1-2 sentence research question
week_2:
  title: Select a public dataset
  action_id: action.select_dataset
  expected_output: Dataset URL and short source note
week_3:
  title: Create a first analysis outline
  status: future_seed_needed
  expected_output: 3-5 analysis questions or chart ideas
week_4:
  title: Draft your first project insight
  status: future_seed_needed
  expected_output: 1 short insight paragraph
```

User-facing explanation:

```text
Your biggest growth opportunity is not choosing the perfect career today. It is creating one piece of evidence that helps you test the path.
```

CTA:

```text
Start recommended project
```

### 3.7 Screen 5: Project Builder

Project:

```yaml
project_id: project.vancouver_housing_dashboard
title: Vancouver Housing Affordability Dashboard
```

Positioning:

```text
This is the first public-data dashboard template. The same structure can later be reused for other Canadian cities or topics.
```

Visible project outputs:

- Research question
- Dataset source note
- Cleaned dataset
- Dashboard
- Insight summary
- Portfolio page
- Resume bullet
- Interview story

Step 1:

```yaml
step_number: 1
title: Define the research question
expected_output: A 1-2 sentence research question.
```

User submission:

```text
I want to understand whether housing affordability in Vancouver has become harder for students and young workers over time.
```

AI review:

```text
Good start. This question is relevant and understandable. To make it easier to analyze, narrow it slightly: compare one housing cost metric with one income or affordability metric over a defined time period.
```

Suggested revision:

```text
How has the rent-to-income burden changed for young people in Vancouver over the last decade, based on available public data?
```

Expected system state:

```yaml
selected_project: project.vancouver_housing_dashboard
completed_project_steps: 1
latest_completed_action: action.define_project_question
```

### 3.8 Screen 6: Dashboard

Dashboard title:

```text
Your Growth Snapshot
```

Expected metrics:

```yaml
career_clarity:
  metric_id: metric.career_clarity
  label: Direction taking shape
  reason: Profile completed, 3 paths compared, and one path saved to test.
project_readiness:
  metric_id: metric.project_readiness
  label: Needs a starting project
  reason: You selected a project and completed Step 1. The next useful step is selecting a dataset.
skill_readiness:
  metric_id: metric.skill_readiness
  label: Needs a starting skill focus
  reason: Excel is beginner and SQL is not started yet. This is normal for a first project.
```

User-facing recommendation:

```text
Your next growth opportunity is project evidence. This week, select one public dataset and explain why it fits your question.
```

CTA:

```text
Continue to dataset selection
```

### 3.9 Screen 7: AI Advisor

User asks:

```text
Should I choose Business Analyst or Data Analyst first?
```

AI Advisor expected answer:

```text
Based on your profile, Business Analyst is the stronger first path to test because you like economics, business, and market analysis, and you do not want a pure coding-heavy route right now.

Data Analyst is still worth exploring, but your current gaps are SQL, dashboard building, and project evidence. The Vancouver housing dashboard is a good low-risk way to test both paths because it can show business analysis and data storytelling.

My recommendation: keep Business Analyst as your primary path for now, use Data Analyst as your technical exploration path, and complete the dataset selection step this week.
```

Safety requirements:

- No guarantee of internship.
- No fixed life decision.
- No “you are not suitable.”

## 4. Demo B: High School Explorer

### 4.1 Persona

```yaml
demo_id: demo.high_school_explorer
label: Demo User B
student_type: high_school_student
student_stage: high_school_explorer
country: Canada
province: all
school: Canadian high school
target_majors:
  - Business
  - Economics
  - Data Science
  - International Relations
liked_subjects:
  - social studies
  - economics
  - math
  - writing
disliked_subjects:
  - advanced coding
interested_industries:
  - business
  - data
  - policy
skills:
  spreadsheet_basics: beginner
  presentation: beginner
  writing: intermediate
projects: []
extracurriculars:
  - school club
  - volunteering
short_term_goal: Understand which university majors and career paths I should explore.
long_term_goal: Choose a direction that connects university study with future career options.
weekly_time_commitment_hours: 3
main_question: I do not know whether I should explore business, economics, data science, or international relations.
```

### 4.2 Demo B narrative

Narrator:

> This student is not looking for job placement. They need a safe exploration path that connects subjects, majors, careers, and a small action.

Product promise:

> The platform does not tell the student what their future should be. It gives them 3 directions to test and one low-pressure action.

### 4.3 Screen 1: Profile onboarding

Differences from university flow:

- Ask target majors instead of current major.
- Ask subjects and activities.
- Ask what they want to understand about future options.
- Do not ask for GPA precision.
- Do not ask for resume upload as a requirement.

Expected system state:

```yaml
completed_profile: true
student_stage: high_school_explorer
primary_question_type: major_career_discovery
```

### 4.4 Screen 2: Profile Summary

User sees:

```text
You are a Canadian high school student exploring Business, Economics, Data Science, and International Relations. You enjoy social studies, economics, math, and writing, but advanced coding may not be your favorite starting point. You have beginner spreadsheet and presentation skills, some club and volunteering experience, and about 3 hours per week to explore. Your main goal is to understand which university and career directions are worth testing.
```

CTA:

```text
Show exploration paths
```

### 4.5 Screen 3: Career / Major Exploration Match

Expected output with current KB:

```yaml
recommended_paths:
  - path_id: career_path.business_analyst
    rank: 1
    fit_label: Worth exploring
    fit_reason: This path connects business, economics, communication, and structured problem-solving without requiring advanced coding at the start.
    main_gap: You need a small project or reflection artifact to test whether you enjoy business analysis.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
  - path_id: career_path.data_analyst
    rank: 2
    fit_label: Test with a small project
    fit_reason: Your interest in math, economics, and data gives this path a signal, but advanced coding dislike means you should start with spreadsheet-based exploration.
    main_gap: Spreadsheet confidence and data storytelling.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
  - path_id: career_path.consultant
    rank: 3
    fit_label: Worth exploring
    fit_reason: This path connects business, writing, communication, and structured problem-solving.
    main_gap: You need to test whether you enjoy ambiguous business questions and explaining your reasoning.
    first_action:
      action_id: action.define_project_question
      title: Define a project research question
    recommended_project_id: project.vancouver_housing_dashboard
```

Visible caveat:

```text
You also mentioned International Relations. Our first KB does not yet include a dedicated policy or international relations path, so this recommendation focuses on the closest available paths for now.
```

CTA:

```text
Save Business Analyst as my first exploration path
```

### 4.6 Screen 4: Exploration Roadmap

Roadmap title:

```text
Your 4-week exploration plan
```

Roadmap content:

```yaml
week_1:
  title: Compare 3 paths
  expected_output: One sentence for why each path is interesting
week_2:
  title: Define a small project question
  action_id: action.define_project_question
  expected_output: 1-2 sentence question
week_3:
  title: Find one public source or article
  action_id: action.select_dataset
  expected_output: Source link and why it helps
week_4:
  title: Write a reflection
  expected_output: What I liked, what I disliked, what I want to test next
```

User-facing explanation:

```text
This is not a final career decision. It is a four-week test to learn what kind of problems you enjoy.
```

### 4.7 Screen 5: First Action

Prompt:

```text
Choose one question that connects a subject you like with a real-world issue.
```

User submission:

```text
I want to understand whether housing costs affect where students choose to study or work in Canada.
```

AI review:

```text
This is a strong exploration question because it connects economics, policy, and student life. To make it easier for a beginner project, narrow it to one city, one population, or one comparison.
```

Suggested revision:

```text
How might housing costs influence where students choose to study or work after high school?
```

Expected system state:

```yaml
saved_primary_path: career_path.business_analyst
completed_reflection_or_project_action: action.define_project_question
```

### 4.8 Screen 6: Dashboard

Expected metrics:

```yaml
career_clarity:
  metric_id: metric.career_clarity
  label: Direction taking shape
  reason: You compared paths and saved one direction to test.
project_readiness:
  metric_id: metric.project_readiness
  label: Needs a starting project
  reason: You wrote a first project question. The next step is finding one source or dataset.
skill_readiness:
  metric_id: metric.skill_readiness
  label: Needs a starting skill focus
  reason: Spreadsheet basics are a good first skill to build for business/data exploration.
```

User-facing recommendation:

```text
Your next step is not choosing your whole future. It is finding one public source that helps answer your question.
```

### 4.9 Screen 7: AI Advisor

User asks:

```text
Should I choose Business, Economics, Data Science, or International Relations?
```

AI Advisor expected answer:

```text
Based on your profile, you do not need to choose a final major today. The strongest first test is a business/economics exploration path because it connects your interest in economics, social studies, writing, and real-world problems.

Data Science is also worth testing, but since you do not like advanced coding as a starting point, begin with spreadsheet-based data exploration before deciding whether to go deeper technically.

International Relations is still relevant to your interests, but our current MVP knowledge base does not yet include a dedicated policy path. A good next step is to frame one question that connects economics, policy, and student life, then find one public source.
```

Safety requirements:

- No admission guarantee.
- No “you should choose this major.”
- No anxiety language.
- No fixed identity label.

## 5. Required Screens For Figma

The clickable prototype should include:

1. Onboarding start
2. Profile questions
3. Profile summary
4. Career match results
5. Career path detail
6. 4-week roadmap
7. Project builder
8. Project step review
9. Growth dashboard
10. AI Advisor

## 6. Required Backend State For MVP

The demo requires these state objects:

```yaml
student_profile:
  completed_profile:
  student_type:
  student_stage:
  major:
  target_majors:
  liked_subjects:
  disliked_subjects:
  skills:
  projects:
  goals:
  weekly_time_commitment_hours:

career_match:
  recommended_paths:
  saved_primary_path:
  score_breakdown:
  uncertainty:

roadmap:
  primary_path_id:
  weekly_tasks:
  task_status:

user_project:
  project_id:
  selected_project:
  completed_project_steps:
  latest_action_id:

dashboard_metrics:
  metric.career_clarity:
  metric.project_readiness:
  metric.skill_readiness:

advisor_context:
  profile_summary:
  saved_primary_path:
  current_roadmap:
  current_project_progress:
```

## 7. Demo Acceptance Criteria

Demo passes only if:

- User completes profile.
- Profile summary reflects user inputs.
- Career Matcher returns 3 paths.
- User saves 1 primary path.
- Roadmap generates a 4-week plan.
- Project/action starts.
- Project Step 1 or exploration action is completed.
- Dashboard updates from real state.
- AI Advisor answers using profile + path + roadmap + project/action progress.
- No screen depends on a generic chat box as the first product experience.

Demo fails if:

- It only shows career recommendations.
- It only shows a chatbot.
- It cannot explain why a path was recommended.
- It cannot produce a next action.
- It uses anxiety/shame language.
- It makes guarantees.

## 8. Open Gaps Before Prototype

Current seed is enough for the first demo loop, but these gaps should be tracked:

- Need more career paths for Software Engineer, Product Manager, Finance Analyst, Policy Analyst, AI Product Manager, Marketing/Growth, UX Designer, Sustainability Analyst.
- Need a high-school-specific exploration roadmap seed.
- Need more actions beyond `define_project_question` and `select_dataset`.
- Need a generic Canadian public-data project template that is not Vancouver-specific.
- Need Career Clarity and Skill Readiness UI scoring examples in the prototype.
- Need source ingestion plan before real RAG.

## 9. Next Step

After this demo script, the next recommended document is:

> `DATA_SCHEMA_ZH.md`

Reason:

- ICP is defined.
- KB schema and seed exist.
- Career Matcher rules exist.
- Demo flow is now concrete.

The next useful step is to define the product data objects that store profile, match result, roadmap, project progress, dashboard metrics, advisor messages, consent, and audit logs.
