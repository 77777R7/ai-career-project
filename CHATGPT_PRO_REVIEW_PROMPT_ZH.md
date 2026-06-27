# ChatGPT Pro Review Prompt

请你作为一个资深产品顾问、AI 产品架构师、教育科技创业顾问和早期 MVP 审稿人，帮我深度评估我们目前为一个 AI Student Growth / Career Planning Platform 做的产品规划与技术规划。

GitHub 仓库链接：

https://github.com/77777R7/ai-career-project

注意：这个仓库目前可能是 private。如果你无法直接打开 GitHub 链接，我会把关键文件内容粘贴给你。请先基于我提供的仓库结构和文件内容做评估，不要泛泛而谈。

## 项目背景

我们想做的是一个面向加拿大用户的 AI 学生成长与职业规划平台。它不是一个普通 chatbot，也不是一个单纯 job board。第一版 MVP 的核心闭环是：

```text
Onboarding -> Profile Summary -> Career Match -> Save Primary Path -> Roadmap -> Project Builder -> Dashboard -> AI Advisor
```

目标用户不是只限大学生，也不是只限高中 11/12 年级。当前边界是：

- 全加拿大，不局限 BC / Vancouver。
- 高中生、大学生、新毕业生、early-career explorers 都可以使用。
- 只要用户有专业选择、职业方向、项目积累、长期成长规划需求，就属于潜在用户。
- 第一版内容方向先聚焦 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided。

第一版要验证的不是“AI 能不能聊天”，而是：

> 一个加拿大有专业/职业规划需求的学生或 early-career explorer，在方向不清楚、项目经历不足的情况下，是否愿意填写 profile，并跟着平台选择方向、生成 roadmap、开始第一个项目。

## 我们目前已经完成的内容

仓库里目前主要是产品与技术规划文档，还没有正式开始写 app 代码。

关键文件：

1. `PROJECT_PLAN_ZH.md`
   - 总体项目计划。
   - 产品定位、MVP 边界、长期愿景。

2. `MVP_ROADMAP_ZH.md`
   - MVP 模块顺序。
   - 明确顺序是：

```text
KB Schema + Seed Content -> Student Profile -> Career Path Matcher -> Roadmap -> Project Builder -> Dashboard -> AI Advisor -> Basic RAG
```

3. `CONTENT_SCHEMA_ZH.md`
   - 知识库 KB 的内容结构。
   - 定义 Career Paths、Skills、Roadmap Templates、Project Templates、Action Templates、Growth Metrics、Knowledge Sources、RAG-ready chunks、Relationship Links。

4. `kb/`
   - 第一批 seed KB 内容，YAML 格式。
   - 已有：
     - Career paths: Business Analyst, Data Analyst, Consultant
     - Skills: Excel, SQL, spreadsheet basics, business analysis, data visualization, data storytelling
     - Project: Vancouver Housing Dashboard
     - Roadmap: Data Analyst university beginner roadmap
     - Actions: Define project question, Select dataset
     - Metrics: Career Clarity, Project Readiness, Skill Readiness, Interview Readiness
     - Sources: StatCan, Job Bank, O*NET, Vancouver Open Data, internal spreadsheet guide

5. `ICP_AND_USER_STORIES_ZH.md`
   - 第一版 ICP 和 user stories。
   - 已经修正为不只面向大学生，也不按年级限制高中生。
   - 覆盖全加拿大。

6. `CAREER_MATCHER_RULES_ZH.md`
   - V1 Career Matcher 规则。
   - 使用 rules + KB relations，不先做 ML。
   - 输出 top 3 career paths、fit score、fit reason、main gap、first action、recommended project、uncertainty。
   - 明确 fit score 是 planning signal，不是命运判断。

7. `DEMO_SCRIPT_ZH.md`
   - 两个 demo persona：
     - Demo User A: University Explorer
     - Demo User B: High School Explorer
   - 演示完整闭环：profile -> match -> roadmap -> project -> dashboard -> advisor。

8. `DATA_SCHEMA_ZH.md`
   - 产品 runtime data schema。
   - 覆盖 profiles、career matches、saved paths、roadmaps、project progress、dashboard metric snapshots、advisor sessions/messages、consent records、audit logs。

9. `ONBOARDING_FLOW_ZH.md`
   - MVP onboarding flow。
   - 目标是薄 profile，不做长问卷。
   - 把字段拆成首次必问、首次建议问、可选、后续 progressive profile。

10. `APP_DATA_MODEL_SQL_DRAFT.sql`
    - Supabase/Postgres draft schema。
    - 有 15 张 MVP 必需表、enums、constraints、indexes、updated_at trigger、RLS draft。

11. `API_CONTRACTS_ZH.md`
    - MVP API contracts。
    - 覆盖：

```text
/api/profile
/api/career-matches
/api/roadmaps
/api/projects
/api/dashboard
/api/advisor
```

12. `IMPLEMENTATION_PLAN_ZH.md`
    - 真正开发顺序。
    - 当前计划是：

```text
Project Scaffold -> KB Loader -> Mock Runtime Store -> Mock API -> Onboarding UI -> Career Matcher Service -> Roadmap Service -> Project Progress -> Dashboard -> AI Advisor -> Supabase Integration
```

核心实现策略：

```text
先用 mock store 跑通完整 demo loop，再接 Supabase。
```

## 请你重点评估的问题

请你不要只给“挺好/可以继续”的泛泛反馈。请你像真正要帮我们避免早期产品走弯路一样，深入指出问题。

请按以下角度评估：

### 1. 产品定位是否清晰

- 这个项目现在到底像不像一个有明确用户价值的产品？
- 它是否和普通 ChatGPT 职业建议有足够区别？
- “Student Growth OS / AI Student Career Planning Platform” 这个方向是否过大？
- 第一版 MVP 的闭环是否足够聚焦？
- 有没有更清晰、更可卖、更容易被用户理解的 positioning？

### 2. ICP 是否正确

- 我们把用户扩到高中生、大学生、新毕业生、early-career explorers，这样是否太宽？
- 第一版是否应该进一步收窄 beachhead？
- 如果要收窄，应该优先选哪一类人？为什么？
- 高中生和大学生是否应该在同一个 MVP 里，还是应该先服务一个？
- “全加拿大”是否合理，还是第一版仍应围绕某些学校/城市做 go-to-market？

### 3. MVP 模块顺序是否合理

目前顺序是：

```text
KB -> Profile -> Career Matcher -> Roadmap -> Project Builder -> Dashboard -> AI Advisor -> Basic RAG
```

请评估：

- 这个顺序是否正确？
- 哪些模块应该更薄？
- 哪些模块是 demo 必需，哪些可以推迟？
- Dashboard 是否应该在 V1 出现？
- AI Advisor 是否应该更早或更晚？
- Basic RAG 是否应该推迟到更后？

### 4. KB 结构是否过重或刚好

请评估 `CONTENT_SCHEMA_ZH.md` 和 `kb/`：

- 这个 KB 结构对 MVP 是否太复杂？
- 哪些字段应该保留？
- 哪些内容类型可以暂缓？
- YAML seed 是否适合第一版？
- 是否应该一开始就抓取真实数据，还是继续人工 seed？
- source/license/compliance 设计是否足够？

### 5. Career Matcher 逻辑是否可信

请评估 `CAREER_MATCHER_RULES_ZH.md`：

- rule-based matcher 是否适合 V1？
- score dimensions 是否合理？
- 会不会给用户一种“被算法判定”的压力？
- 如何更好表达 uncertainty？
- 推荐 top 3 paths 是否合理？
- 目前只 seed Business Analyst、Data Analyst、Consultant 是否足够 demo？
- 哪些 career paths 应该下一批补？

### 6. Roadmap + Project Builder 是否能形成真正价值

请评估：

- 从 career match 到 4-week roadmap 的逻辑是否自然？
- Project Builder 是否是这个产品区别于普通 career advice 的关键？
- 第一个项目用 Vancouver Housing Dashboard 是否合适？如果全加拿大，是否应该换成更全国通用的 project？
- 高中生版本的 project/action 应该怎样设计，才不会像求职产品？

### 7. Data schema 和 SQL 是否合理

请评估 `DATA_SCHEMA_ZH.md` 和 `APP_DATA_MODEL_SQL_DRAFT.sql`：

- 15 张表对 MVP 是否太多？
- 哪些表可以后置？
- 哪些字段可能会给实现带来不必要复杂度？
- consent/audit logs 是否设计得过早，还是必要？
- Supabase/Postgres 设计是否有明显问题？
- mock store 先跑通再接 Supabase，这个策略是否正确？

### 8. API contract 是否合理

请评估 `API_CONTRACTS_ZH.md`：

- API 面积是否过大？
- 是否应该合并或拆分某些 endpoint？
- 前端是否能按这些 API 顺利实现？
- save primary path 放在 career match 下是否合理？
- Dashboard recompute API 是否应该存在？
- Advisor 的 proposed profile patch 设计是否合理？

### 9. Onboarding 是否足够轻

请评估 `ONBOARDING_FLOW_ZH.md`：

- 首次 onboarding 还是不是太长？
- 哪些问题可以删？
- 哪些字段必须保留？
- 高中生和大学生是否应走同一 onboarding？
- 如何提高用户完成率？
- Profile Summary 是否应该在 Career Match 前出现？

### 10. Implementation plan 是否适合真正开始写代码

请评估 `IMPLEMENTATION_PLAN_ZH.md`：

- Phase 顺序是否正确？
- 是否应该先做 clickable prototype，再写代码？
- Mock API + mock store 策略是否合理？
- 第一个开发 sprint 应该怎么切？
- 哪些技术债会在后面爆？

## 请你输出的格式

请用中文回答，结构要清晰。

请按这个格式输出：

1. 总体评分：1-10 分，并解释为什么。
2. 目前最强的 5 个地方。
3. 目前最危险的 5 个问题。
4. 你会怎么重新收窄 MVP。
5. 你建议我们下一步先做什么，按优先级排序。
6. 哪些文档或模块应该删减、合并或推迟。
7. 哪些内容应该继续补充。
8. 对 GitHub repo 结构的建议。
9. 对第一版 demo 的建议。
10. 最后给一个 revised 4-week execution plan。

请务必具体到文件和模块，不要只讲原则。

如果你认为我们现在做得过度规划，也请直接指出，并告诉我们如何切回最小可验证版本。
