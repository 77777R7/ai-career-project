# GPT Pro Optimization Summary

日期：2026-06-27

## 1. 优化来源

本文件记录根据 GPT Pro 评估后，对当前 AI Student Growth Platform MVP 做出的收窄和优化决策。

核心判断：

> 当前方向成立，但规划接近完整平台。第一版必须切回最小可验证版本，先证明一个学生会填写 profile、保存 career path、生成 4-week roadmap、开始第一个 project step，并觉得它比直接问 ChatGPT 更有用。

## 2. 新的 V1 定位

旧定位偏宽：

> 全加拿大高中生、大学生、新毕业生、early-career explorers 都作为第一版主用户。

优化后 V1 主定位：

> 面向加拿大大学生的 AI Career Direction + Project Builder，帮助 business/data/tech-adjacent 学生在方向不清楚、项目经历不足时，选择一个可探索 career path，并开始第一个 portfolio project。

## 3. ICP 调整

### 3.1 V1 Primary ICP

V1 主 ICP：

> 加拿大大学低年级到大四学生，尤其是 Commerce、Economics、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided 背景，正在探索 business、data、consulting、product、software、policy 等方向，但缺少清晰 roadmap 和项目证据。

### 3.2 Secondary ICP

保留但不作为第一波主验证：

- 高中生：作为 exploration mode / secondary demo。
- 新毕业生：如果问题仍是方向和项目证据，可进入大学生主流的扩展版本。
- Early-career explorers：后续职业转向版本，不进入第一版主 demo。

### 3.3 GTM 边界

产品内容保持 Canada-wide。

市场验证采用：

> Canada-wide product, campus-cluster go-to-market.

第一波访谈和测试优先从可触达学生圈开始，例如 UBC、SFU、Toronto、Waterloo、McGill、Western、Queen's 等。

## 4. MVP 模块轻重调整

### 4.1 保留为 V1 demo loop 必需

```text
KB Seed
-> Thin Profile / Onboarding
-> Profile Summary
-> Career Matcher
-> Save Primary Path
-> 4-week Roadmap
-> Project Recommendation
-> Project Step 1-2
-> Growth Snapshot
```

### 4.2 做薄

- Dashboard 改为 `Growth Snapshot`。
- AI Advisor 改为 `Advisor Lite`，只回答和当前 profile/path/roadmap/project 相关的问题。
- Metrics 只展示 `Career Clarity`、`Project Readiness`、`Skill Readiness`、`Next Actions`。

### 4.3 推迟

- Full Dashboard。
- Basic RAG / vector search。
- Supabase production schema。
- Full consent and audit logs。
- Advisor proposed profile patch。
- Full high-school roadmap。
- Application tracker、auto-apply、job board。

## 5. KB 优化

根据反馈补充：

### 5.1 Career Paths

新增：

- `career_path.product_manager`
- `career_path.software_engineer`
- `career_path.policy_analyst`

现在 seed career paths 从 3 条扩展到 6 条：

- Business Analyst
- Data Analyst
- Consultant
- Product Manager
- Software Engineer
- Policy Analyst

### 5.2 Skills

新增：

- `skill.product_thinking`
- `skill.programming_fundamentals`
- `skill.policy_research`

### 5.3 Projects

新增：

- `project.canadian_housing_cost_living_dashboard`
- `project.ai_student_growth_prd`
- `project.canada_ai_workforce_policy_brief`
- `project.major_career_exploration_map`

其中 `project.canadian_housing_cost_living_dashboard` 成为全国版主项目，Vancouver 保留为 default demo city，而不是产品边界。

## 6. API / Data 优化口径

### 6.1 API

`API_CONTRACTS_ZH.md` 保留完整 MVP contracts，但增加 Demo API / Full MVP API 的区分。

V1 demo 不要求前端直接调用：

```text
POST /api/dashboard/recompute
```

Growth Snapshot recompute 应由事件内部触发。

### 6.2 Data / SQL

`DATA_SCHEMA_ZH.md` 和 `APP_DATA_MODEL_SQL_DRAFT.sql` 保留，但标记为 Phase 2 persistence schema draft。

第一轮 demo 使用 mock runtime store，不先固化 production DB。

## 7. 下一步执行优先级

按照优化后的顺序：

1. 更新文档和 KB，收窄 V1。
2. 做 clickable prototype 或直接做极薄本地 prototype。
3. 建 KB validator。
4. 用 5 个 sample profiles 手动跑 matcher 输出。
5. 做 mock API + mock store。
6. 跑通 University Explorer demo loop。
7. 做 10-30 个用户测试。
8. 再决定是否进入 Supabase version。

## 8. 新的 4 周执行目标

第一版 4 周目标不是完整平台，而是：

> 一个 profile，一个 career match，一个 4-week roadmap，一个 project step，一个 growth snapshot，一个 advisor lite。

只要用户能说：

> 这个比我直接问 ChatGPT 更懂我，而且真的让我开始做第一个项目。

这个 MVP 就有继续加深的价值。
