# ICP 与 User Stories

日期：2026-06-26

更新：2026-06-27，根据 GPT Pro 评估，V1 主 ICP 收窄为 Canadian university explorers；高中生、新毕业生和 early-career users 保留为 secondary / demo / later expansion。

## 1. 文档目的

本文件用于锁定第一版 MVP 的目标用户、demo persona 和用户故事。

后续所有产品、KB、Career Matcher、Roadmap、Project Builder、Growth Snapshot 和 Advisor Lite 的优先级，都先按这个文件判断。

第一版不按年级硬性排除用户。只要用户有职业规划、专业选择、项目积累或长期成长规划需求，都可以使用；但 V1 的产品设计、demo 和验证指标先按大学生 explorer 优先。

第一版要验证的核心问题是：

> 一个加拿大大学生 explorer，在方向不清楚、项目经历不足的情况下，是否愿意填写 profile，并跟着平台选择方向、生成 4-week roadmap、开始第一个项目。

## 2. 第一版主 ICP

### 2.1 主 ICP 定义

第一版主 ICP：

> Canadian university explorers：在加拿大读大学或 college，来自 business / data / tech-adjacent 背景，职业方向不清晰、项目证据不足，想在 4 周内从“迷茫”进入“选定主路径并开始项目”的学生。内容方向先聚焦 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided。

更具体地说：

> 用户知道自己需要为实习、项目积累或职业方向做准备，但不确定自己适合 Data Analyst、Business Analyst、Consulting、Product、Software、Policy 或 AI-related paths，也不知道应该做什么项目来验证兴趣和证明能力。

### 2.2 主 ICP 的典型特征

学业阶段：

- 大学生或 college student，不限定具体年级，但第一批验证更关注低年级、转方向学生、国际学生和缺项目证据的学生。
- 高中生、新毕业生和 early-career explorers 如果核心问题仍然是方向、项目和成长路线，可以作为 secondary mode 使用。
- 当前专业、目标专业或兴趣方向先限定为 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided。
- 还没有形成清晰职业路径。

地理和市场语境：

- 全加拿大为主，不局限 BC / Vancouver。
- 可以覆盖 BC、Ontario、Alberta、Quebec 等省份，但第一版内容先做全国通用 career/path/project 逻辑。
- Vancouver / UBC / SFU 可以作为 demo、访谈或项目样例，但不是产品边界。

典型痛点：

- 不知道专业和职业之间怎么对应。
- 不知道 Data Analyst、Business Analyst、Consulting、Finance、Product 的真实差异。
- 没有像样的 portfolio project。
- 不知道先学 SQL、Excel、Python、case interview 还是 resume。
- 看过很多建议，但没有具体下一步。
- 担心自己没有实习经历，简历空。
- 对 ChatGPT 的泛泛回答不满意，因为它不了解自己的长期背景。

使用动机：

- 想在 1-3 个月内找到一个更清晰的方向。
- 想做一个能放进 resume / portfolio / interview story 的项目。
- 想知道每周具体该做什么。
- 想有一个持续跟踪自己的系统，而不是一次性问答。

## 3. 次级 ICP

次级 ICP 不是第一版主入口，但会影响产品设计。高中生不被硬性排除，但 V1 不为高中生做完整升学规划。

### 3.1 高中生 Exploration Mode

定义：

> 对大学专业、职业方向和项目探索有需求的高中生，不限定具体年级。

为什么重要：

- 高中生也有 major-career fit 和项目探索需求。
- 家长可能参与付费和决策。
- 但高中生会把产品带向升学规划、课外活动、申请包装和未成年人隐私，复杂度更高。

第一版处理方式：

- 保留 demo persona 和轻量 exploration project。
- 输出表达为“探索路线”和“验证兴趣”，不表达为就业承诺或录取承诺。
- 不做完整高中升学规划、选校规划、申请文书或家长 dashboard。

### 3.2 国际学生

定义：

> 加拿大大学或 college 的国际学生，对加拿大 hiring norms、实习节奏、简历表达、networking 和本地项目经验不熟悉。

为什么重要：

- 痛点强。
- 愿意寻找外部工具和指导。
- 可能更重视本地语境和长期规划。

第一版处理方式：

- 作为主 ICP 的叠加标签。
- 不把产品做成 immigration advisor。
- 不回答 PGWP、签证、身份状态结论。
- 可以提供官方资源导航和 advisor question list。

### 3.3 已经进入密集求职阶段的用户

定义：

> 已经进入密集求职阶段，主要需求是投递、面试、referral、application tracker 或 offer negotiation 的用户。

为什么重要：

- 痛点强，也可能付费。
- 但需求更偏 job-search execution，容易把 MVP 带向 Teal / Simplify / LinkedIn 竞争场。

第一版处理方式：

- 如果他们的核心问题仍然是方向、项目证据和成长路线，可以使用主产品流。
- 如果他们只需要求职投递工具，则不作为主产品流。
- 不优先做 application tracker、auto-apply、job board。

### 3.4 家长

定义：

> 正在帮助孩子思考大学专业、职业方向和课外项目的家长。

为什么重要：

- 家长可能付费。
- 会关注孩子方向是否清晰、是否有可见成长、是否避免走弯路。
- 但家长端产品会增加隐私、表达和焦虑管理复杂度。

第一版处理方式：

- 不做家长 dashboard。
- 不做大学申请承诺。
- 不制造焦虑。
- 可以在访谈中了解付费意愿，但产品主体验先给学生。

## 4. 第一版不服务谁

V1 暂不优先做这些独立产品流：

- 需要移民、法律、医疗、心理健康结论的用户。
- 只想自动投简历的 job seekers。
- 只想刷题或求职面试题库的用户。
- 已有明确职业方向、只需要高级 networking / referral / job matching 的用户。
- 学校管理员、家长、雇主、职业中介后台用户。
- 低龄用户的单独儿童产品体验。

原因：

- 这些需求会把产品拉向不同平台形态。
- 第一版要先证明 student growth loop，不做全场景教育工具。

## 5. MVP 主用户故事

### User Story 1: 迷茫学生获得方向

作为一名有专业/职业规划需求的学生，我想填写自己的背景、兴趣、技能和目标，让系统推荐 3 条适合我当前阶段的职业路径，这样我能从“不知道做什么”变成“知道先探索哪几个方向”。

验收标准：

- 用户能在 10-15 分钟内完成 profile。
- 系统生成 profile summary。
- 系统推荐 3 条 career path。
- 每条推荐都有 fit reason、main gap、first action。
- 用户能保存一个 primary path。
- 高中生版本会把建议表达成探索路线，不表达成就业承诺。

### User Story 2: 方向变成 4 周行动计划

作为一名选择了主职业路径的学生，我想看到一个 4 周行动计划和 3/6/12 个月路线，这样我知道这周应该做什么，而不是只得到抽象建议。

验收标准：

- Roadmap 基于 profile 和 primary path 生成。
- Roadmap 不只是文本建议，而是 task list。
- 每个 task 有状态：not started、in progress、done、blocked、need help。
- 用户能完成至少一个 task。

### User Story 3: 学生开始第一个项目

作为一名缺少项目经历的学生，我想获得一个适合我方向的项目模板，并被一步一步带着完成第一个步骤，这样我能开始积累 portfolio evidence。

验收标准：

- 系统推荐至少 1 个 project。
- 项目解释为什么适合当前职业路径。
- 用户能进入 Project Builder。
- 用户能完成 Step 1：Define research question。
- 系统保存 project progress。
- Growth Snapshot 的 Project Readiness 更新。

### User Story 4: Growth Snapshot 告诉我下一步

作为一名正在探索职业方向的学生，我想看到自己的 Career Clarity、Skill Readiness 和 Project Readiness，这样我知道现在最该补什么。

验收标准：

- Growth Snapshot 从真实 profile、path、roadmap、project progress 计算。
- 不使用羞辱式或焦虑式语言。
- 显示 strongest area。
- 显示 next growth opportunity。
- 显示 this week next action。

### User Story 5: Advisor Lite 根据我的状态回答

作为一名学生，我想问 Advisor Lite “我该选 Data Analyst 还是 Business Analyst？” 并得到基于我 profile、roadmap 和 project progress 的回答，而不是普通 ChatGPT 式泛泛建议。

验收标准：

- Advisor Lite 引用用户 profile。
- Advisor Lite 引用 primary path 或 saved paths。
- Advisor Lite 给出比较框架。
- Advisor Lite 给出下一步行动。
- Advisor Lite 不保证 offer、录取或人生最优路径。
- 高风险问题会转官方资源或 human advisor。

## 6. Demo Persona

第一版 demo persona 分成两个。大学生 demo 用来验证 internship/project readiness，高中生 demo 用来验证 major/career discovery。高中生 demo 只是样例，不代表产品只服务某个年级。

### 6.1 Demo Persona A: 大学生

身份：

> Demo User A: University Explorer

地点：

> Canada

学生类型：

> university_student

是否国际学生：

> 可选版本 A：international_student  
> 可选版本 B：domestic_student

默认 demo 先用 international_student，因为痛点更集中，但不要把产品定位成只服务国际学生。

### 6.2 Profile 输入

```yaml
student_type: university_student
student_stage: university_beginner
school: UBC
major: Economics
country: Canada
province: all
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

### 6.3 系统应该生成的 Profile Summary

```text
Demo User A is a first-year Canadian university Economics student exploring business, data, and consulting-related paths. They enjoy economics, business, and market analysis, but do not want a pure coding-heavy path. They currently have beginner Excel and presentation skills, no SQL or Python experience, and no portfolio project or internship yet. Their short-term goal is to find a clearer internship direction before second year, with around 5 hours per week available for structured preparation.
```

### 6.4 系统应该推荐的 3 条 Career Paths

推荐顺序：

1. Business Analyst
2. Data Analyst
3. Consultant

如果第一版 KB 还没有 Consultant，demo 可以先显示：

1. Business Analyst
2. Data Analyst
3. Product Analyst / Consulting Analyst placeholder

但正式 MVP 应补 `career_path.consultant`。

### 6.5 推荐理由样例

Business Analyst：

- Fits Economics + business interest.
- Lower coding barrier than software-heavy paths.
- Needs stronger evidence through a business/data project.

Data Analyst：

- Strong adjacent fit for Economics and market analysis.
- Main gap is SQL, dashboard building, and project evidence.
- Good path to test through a public-data dashboard project.

Consultant：

- Fits interest in business problems and communication.
- Main gap is structured case practice and networking.
- Should be tested through a small market or strategy case.

### 6.6 推荐的第一项目

项目：

> Canadian Housing and Cost of Living Dashboard

项目 ID：

> `project.canadian_housing_cost_living_dashboard`

为什么推荐：

- 对 Economics 学生自然。
- 数据主题可以换成加拿大本地城市、住房、消费、就业或教育相关问题。
- 不需要一开始会复杂 coding。
- 能证明 Excel、data visualization、data storytelling。
- 后续可以转化成 resume bullet 和 interview story。

### 6.7 Demo 完成线

Demo 必须跑到：

1. Demo User A 完成 onboarding。
2. 系统生成 profile summary。
3. 系统推荐 3 条 path。
4. Demo User A 保存 Business Analyst 或 Data Analyst 为 primary path。
5. 系统生成 4 周 roadmap。
6. 系统推荐 Canadian Housing and Cost of Living Dashboard。
7. Demo User A 完成 Project Step 1：Define research question。
8. Demo User A 完成 Project Step 2：Select a dataset。
9. Growth Snapshot 的 Project Readiness 从 0 更新到一个低但真实的分数。
10. Advisor Lite 给出下一步：Make the first chart。

如果 demo 只停在 career recommendation，就还不是完整 MVP。

### 6.8 Demo Persona B: 高中生样例

身份：

> Demo User B: High School Explorer

地点：

> Canada

学生类型：

> high_school_student

目标方向：

> Undecided between Business, Economics, Data Science, and International Relations

Profile 输入：

```yaml
student_type: high_school_student
student_stage: high_school_explorer
school: Canadian high school
target_majors:
  - Business
  - Economics
  - Data Science
  - International Relations
country: Canada
province: all
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

高中生系统输出应该更偏探索，不按年级硬切：

- 推荐 3 条探索方向，不说就业结论。
- 解释专业和职业的关系。
- 推荐低门槛 project 或 reflection task。
- 给 4 周 exploration plan。
- 避免制造焦虑，不使用 “behind” 或 “not ready” 表达。

高中生 demo 的完成线：

1. Demo User B 完成 profile。
2. 系统生成 profile summary。
3. 系统推荐 3 条探索方向。
4. Demo User B 保存一个 primary exploration path。
5. 系统生成 4 周 exploration roadmap。
6. 系统推荐一个 beginner project 或 career reflection action。
7. Growth Snapshot 更新 Career Clarity / Project Readiness 的早期信号。

## 7. 用户故事优先级

### P0: 必须支持

- 完成 student profile。
- 生成 profile summary。
- 推荐 3 条 career path。
- 保存 primary path。
- 生成 4 周 roadmap。
- 推荐第一个 project。
- 完成 project Step 1-2。
- Growth Snapshot 更新 Project Readiness。
- 对高中生支持 Career Discovery Track 的低风险版本。

### P1: Beta 前支持

- Advisor Lite 根据 profile + path + roadmap + project progress 回答。
- 支持 blocked / need help 状态。
- 生成 resume bullet draft。
- 生成 basic interview story。
- 支持 source / risk 标签。

### P2: 暂缓

- 家长端。
- 学校 admin dashboard。
- 雇主端。
- application tracker。
- auto apply。
- full RAG over large web crawl。
- transcript parsing。
- immigration-specific guidance。

## 8. Career Matcher 规则启示

这个 ICP 文件直接决定 Career Matcher V1 的输入和权重。

### 8.1 必须读取的 profile inputs

```yaml
student_stage:
school:
major:
target_majors:
liked_subjects:
disliked_subjects:
interested_industries:
skills:
projects:
internships:
short_term_goal:
long_term_goal:
weekly_time_commitment_hours:
main_question:
```

### 8.2 第一版推荐输出

Career Matcher 输出 3 条：

```yaml
recommended_paths:
  - path_id:
    fit_score:
    fit_reason:
    main_gap:
    first_action:
    recommended_project_id:
    uncertainty:
```

### 8.3 第一版评分维度

初始权重：

| 维度 | 权重 |
| --- | ---: |
| 兴趣匹配 | 25% |
| 当前技能匹配 | 20% |
| 专业/课程匹配 | 15% |
| 项目/经历匹配 | 15% |
| 学生目标匹配 | 15% |
| 可投入时间匹配 | 10% |

注意：

- Fit score 是 planning signal，不是人生判断。
- 不说 “you are not fit”。
- 不输出歧视性或焦虑式结论。
- 对缺失信息要写 uncertainty。

### 8.4 Demo persona 的预期评分方向

对 Demo User A：

Business Analyst 应该高：

- Economics + business interest 匹配。
- 不喜欢 pure coding，但能接受分析。
- 当前技能门槛相对可启动。

Data Analyst 应该中高：

- Economics + data / market analysis 匹配。
- 但 SQL、dashboard、technical project 是 gap。

Consultant 应该中：

- business problem-solving 匹配。
- 但 case practice、networking、communication evidence 还不足。

Software Engineer 不应该排前 3：

- 用户明确不喜欢 pure coding。
- 当前无 coding skill。
- 如果推荐，只能作为 exploration path，不作为 primary。

Finance Analyst 可以作为备选：

- Economics 相关。
- 但 profile 未显示强 finance interest 或 modeling skill。

对 Demo User B：

Business Analyst / Business exploration 应该较高：

- Business、Economics、writing、presentation 兴趣匹配。
- 可以通过低门槛 business/data 项目探索。

Data Analyst / Data Science exploration 应该中高：

- Math 和 data interest 匹配。
- 但 advanced coding dislike 是需要测试的 challenge。

Policy / International Relations exploration 应该中：

- Social studies、writing、International Relations interest 匹配。
- 但第一版 KB 需要补充 Policy Analyst / International Relations-specific paths 才能稳定推荐。

## 9. 访谈验证问题

第一轮访谈围绕这些问题：

1. 你现在最不确定的是专业、职业、技能、项目、实习，还是简历？
2. 如果一个平台让你花 10 分钟填写 profile，你愿意填到什么程度？
3. 你是否愿意上传 resume 或 LinkedIn？如果不愿意，为什么？
4. 你现在最想比较哪 2-3 条职业路径？
5. 你有没有做过 portfolio project？如果没有，最大的阻碍是什么？
6. 你更想要 3 个月路线图，还是本周任务？
7. 如果 AI 推荐一个项目并带你做第一步，你愿意开始吗？
8. 你希望 Growth Snapshot 告诉你什么？什么表达会让你焦虑？
9. 你会为这个工具付费吗？谁会付费，你还是父母？
10. 你觉得它和 ChatGPT 最大区别应该是什么？

## 10. 成功指标

第一版用户验证成功，不是看用户说 “interesting”，而是看行为：

- 70% 访谈用户愿意完成 profile。
- 50% 完成 profile 的用户愿意保存一个 path。
- 40% 愿意生成 roadmap。
- 30% 愿意开始 project。
- 20% 愿意完成 project Step 1。
- 至少 5 个用户愿意二次跟进。
- 至少 5 个用户愿意加入 beta waitlist。
- 至少 3 个用户表达明确付费或推荐给朋友的意愿。

## 11. 对后续工作的约束

后续工作按以下约束执行：

- Career Matcher 先服务 Demo User A 这类 Canadian university explorer。
- Demo User B 保留为 secondary mode，用于验证高中生 exploration 表达。
- Roadmap 先服务 university_beginner 的基础版本，高中生 exploration roadmap 作为轻量样例。
- Project Builder 先跑通 Canadian Housing and Cost of Living Dashboard。
- Growth Snapshot 先把 Project Readiness 算清楚。
- Advisor Lite 先回答 career/path/project/action 问题。
- RAG 后置；先用 curated context 围绕 Job Bank、O*NET、StatCan 和项目数据源做小范围官方来源。
- 不为了家长、学校、雇主而打乱第一版学生端闭环。

## 12. 下一步

下一步做：

> `CAREER_MATCHER_RULES_ZH.md`

它应该定义：

- 输入字段。
- scoring dimensions。
- 每个维度怎么算。
- 如何使用 `kb/relations.yaml`。
- 如何处理 missing data。
- 如何输出 top 3 paths。
- 如何生成 fit_reason、main_gap、first_action。
- 如何避免风险表达。
