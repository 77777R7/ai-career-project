# MVP 执行 Roadmap

日期：2026-06-26

目标：这个 roadmap 是后续执行顺序。后面做产品、原型、代码、内容库、AI prompt、数据库和测试，都按这里的阶段走。

## 总原则

第一版只验证一个核心闭环：

> Student Profile -> Career Path Match -> Roadmap -> Project Builder -> Dashboard -> AI Advisor

不要先做完整平台。不要先做纯 chatbot。不要先做 landing page 漂亮包装。先把学生从“迷茫”带到“选定方向并开始第一个项目”的闭环跑通。

第一版的核心 demo：

> 一个加拿大有专业/职业规划需求的学生填写背景后，系统推荐 3 条职业/专业探索路径，生成 4 周计划，推荐一个项目或探索 action，并带他完成第一步。

## KB 和 RAG 的位置

这里要分清楚两件事：

1. KB 内容层：从阶段 0 就开始搭。
2. RAG 检索层：等 Profile / Career Match / Roadmap / Project Builder / AI Advisor 的基本上下文跑通后再接。

原因：

- Career Path、Skill、Roadmap Template、Project Template 本身就是第一版 KB。
- 如果没有 KB，Career Match 和 Roadmap 会变成纯 prompt 输出，不稳定。
- 但如果一开始就做复杂 RAG，会拖慢核心闭环验证。

所以真实顺序是：

> KB Schema + Seed Content -> Student Profile -> Career Path Matcher -> Roadmap -> Project Builder -> Dashboard -> AI Advisor -> Basic RAG

也就是说，KB 已经包括在 roadmap 里，而且是最早要做的地基之一；只是向量检索和引用回答可以放到后面。

## 阶段 0：项目地基

状态：下一步先做

目标：先把产品骨架、内容骨架、数据骨架定住。没有这个地基，后面做出来会像一堆 AI 页面，而不是一个系统。

### 0.1 确定第一版 ICP

默认 ICP：

> 全加拿大有专业/职业规划需求的高中生、大学生、新毕业生和 early-career explorers。内容方向先聚焦 Economics、Commerce、Business、Statistics、CS、Data Science、Cognitive Systems、International Relations 或 undecided。

第一版不按年级限制使用，但内容和 demo 先围绕上述方向打深。

暂不作为主入口：

- 家长端。
- 学校管理端。
- 雇主端。
- 已经进入密集求职阶段的高级 job-search users。
- 低龄用户的单独儿童产品体验。

验收标准：

- 有 1 个全国主 ICP，按规划需求定义，而不是按年级定义。
- 有高中生和大学生两个 demo persona。
- 有 3 个以上典型用户故事。

### 0.2 建内容库结构

先用 Markdown / Notion / Airtable 均可。代码前先有内容结构。

这一阶段搭的是 KB 的内容和 schema，不是 RAG 技术。它会直接支撑 Career Path Matcher、Roadmap Generator、Project Builder 和 AI Advisor。

必须建 7 类主内容，另加 2 个支撑结构：

1. Career Paths
2. Skills
3. Roadmap Templates
4. Project Templates
5. Action Templates
6. Growth Metrics / Rubrics
7. Knowledge Sources
8. Relationship Links
9. RAG-Ready Chunks

验收标准：

- 12 条 career path 有统一字段。
- 6 个 project template 有统一字段。
- actions 能变成 roadmap task 和 project step。
- metrics 能解释 dashboard 分数从哪里来。
- relationships 能说明 career path、skill、project、action、metric、source 之间的关系。
- 12 条 career path 和 6 个 project template 可以作为 seed KB 导入产品。
- 每条知识来源记录 license / source / risk level。

### 0.3 建产品数据 schema

先写 schema 文档，再进数据库。

第一版核心对象：

- student_profile
- career_path
- career_match
- roadmap
- roadmap_task
- project_template
- user_project
- project_step_progress
- advisor_message
- dashboard_metric
- knowledge_source
- consent_record

验收标准：

- 每个对象有字段定义。
- 每个对象知道由哪个模块使用。
- 能完整描述一名学生从 onboarding 到项目第一步的状态变化。

### 0.4 写第一版 demo script

默认 demo persona：

> Persona A: first-year Canadian university Economics student, likes business and data, dislikes pure coding, has basic Excel, no SQL, wants internship direction, can spend 5 hours per week.

> Persona B: Canadian high school student, undecided between Business, Economics, Data Science, and International Relations, wants to understand major-career fit, can spend 3 hours per week.

Demo 必须展示：

1. 填 profile。
2. 获得 3 条 path：Business Analyst、Data Analyst、Consulting Analyst。
3. 选择主 path。
4. 生成 4 周 roadmap。
5. 推荐 Vancouver Housing Affordability Dashboard 或一个等价的 Canadian public-data beginner project。
6. 完成 Project Step 1 或高中生 exploration action：Define research question。
7. Dashboard 更新。

验收标准：

- demo script 可以 5 分钟讲完。
- 每一步都有用户看到的屏幕结果。

## 阶段 1：人工验证

目标：先手动证明学生真的需要这个闭环。不要马上写完整产品。

### 1.1 用户访谈

样本：

- 10 个大学低年级学生。
- 10 个国际学生或新毕业生。
- 10 个高中高年级或家长。

访谈要验证：

- 他们真正焦虑的是方向、项目、技能、实习，还是简历？
- 他们会不会填写 profile？
- 他们是否相信 AI 生成的路线？
- 他们是否愿意开始一个项目？
- 谁会付钱，为什么现在付钱？

验收标准：

- 至少 30 份访谈记录。
- 至少 10 个明确高痛点用户。
- 至少 5 个愿意二次跟进。
- 至少 5 个愿意开始项目。

### 1.2 手动生成 Student Growth Report

先不用系统自动生成。人工做 10 份报告。

每份报告包括：

- Profile Summary。
- 3 条 career path 推荐。
- 选择建议。
- 4 周行动计划。
- 1 个推荐项目。
- 第一步任务。

验收标准：

- 10 份报告完成。
- 学生能指出“这比 ChatGPT 更懂我”的地方。
- 学生愿意根据报告做第一步行动。

### 1.3 手动跑第一个项目 cohort

选择 5-10 个学生，带他们做项目第一步。

优先项目：

> Vancouver Housing Affordability Dashboard

验收标准：

- 50% 以上完成 Step 1。
- 30% 以上完成 Step 2。
- 收集卡点：数据源、工具、动机、时间、AI 反馈质量。

## 阶段 2：Clickable Prototype

目标：在写代码前，让用户看到“这像一个平台”。

工具：Figma

### 2.1 必做页面

1. Onboarding
2. Profile Summary
3. Career Match Results
4. Career Path Detail
5. Roadmap
6. Project Builder
7. Growth Dashboard
8. AI Advisor

### 2.2 页面顺序

Prototype 入口不是 landing page，而是 onboarding。

用户流：

> Onboarding -> Profile Summary -> Career Match -> Roadmap -> Project Builder -> Dashboard -> AI Advisor

验收标准：

- 20 个用户看 prototype。
- 70% 以上能理解产品在做什么。
- 50% 以上愿意继续到 roadmap/project。
- 用户不会把它理解成普通 ChatGPT wrapper。

## 阶段 3：技术基础搭建

目标：搭建可以长期扩展的最小技术底座。

推荐栈：

- Next.js
- TypeScript
- Tailwind CSS
- shadcn/ui
- Supabase Auth
- Supabase Postgres
- Supabase Storage
- pgvector
- Vercel

### 3.1 初始化应用

任务：

- 创建 Next.js app。
- 接入 Tailwind / shadcn。
- 建基础路由。
- 建 UI layout。
- 建 Supabase client。
- 配置环境变量。

验收标准：

- 本地 dev server 可运行。
- Vercel 可部署。
- 有基本 app shell，不是 landing page。

### 3.2 建数据库和权限

先建最小表：

- profiles
- student_profiles
- career_paths
- career_matches
- roadmaps
- roadmap_tasks
- project_templates
- user_projects
- project_step_progress
- advisor_messages
- dashboard_metrics
- knowledge_sources
- consent_records

验收标准：

- 用户只能读写自己的 student data。
- 公共 career_paths / project_templates 可读。
- consent_records 可记录。

### 3.3 建 seed content

先把内容 seed 到数据库。

第一批 seed：

- 12 条 career path。
- 6 个 project template。
- 7 个 dashboard metrics。
- 20-30 条 knowledge source metadata。

验收标准：

- 前端能读取真实数据库内容。
- 没有把 career path 写死在组件里。

## 阶段 4：MVP 功能按顺序搭建

这个阶段严格按顺序做。不要跳到后面的 AI Advisor 或 dashboard。

### 4.1 Student Profile Onboarding

为什么先做：

> Profile 是整个产品的长期记忆。没有 profile，后面的推荐和 AI 都会变泛。

V1 功能：

- 账号登录。
- 学生类型。
- 年级、学校、专业。
- 兴趣和不喜欢的方向。
- 技能自评。
- 目标。
- 每周可投入时间。
- 可选 resume / LinkedIn 文本输入。
- 生成 profile summary。

验收标准：

- 一个用户能完整提交 profile。
- profile 写入数据库。
- profile summary 可展示。
- onboarding 不超过 10-15 分钟。

### 4.2 Career Path Matcher

为什么第二个做：

> 用户第一价值时刻是“平台理解我，并给我 3 条方向”。

V1 功能：

- 从 profile 读取输入。
- 推荐 3 条 career path。
- 每条 path 有 fit reason、main gap、first action。
- 用户可以保存 primary path。

初期推荐逻辑：

- 规则打分 + LLM 解释。
- 不做复杂 ML。

验收标准：

- 用户能看到 3 条推荐。
- 用户可以保存主路径。
- 推荐原因不是空泛文字。

### 4.3 Personalized Roadmap

为什么第三个做：

> 方向必须变成计划，否则产品还是 advice。

V1 功能：

- 根据 primary path 生成 4-week plan。
- 展示 3/6/12 个月路线。
- 每周任务可打勾。
- 任务状态可更新。

验收标准：

- 生成 roadmap。
- 保存 roadmap。
- 用户能完成第一个 task。
- roadmap 更新 dashboard 需要的数据。

### 4.4 Project Builder

为什么第四个做：

> 这是你们和普通 ChatGPT 拉开差距的核心。

V1 功能：

- 根据 primary path 推荐 1-2 个项目。
- 用户选择项目。
- 展示项目步骤。
- 用户提交 Step 1 输出。
- AI 或规则给 Step 1 反馈。
- 记录进度。

第一版只要求完整跑通一个项目：

> Vancouver Housing Affordability Dashboard

验收标准：

- 用户能开始项目。
- 用户能完成 Step 1。
- 系统能保存项目进度。
- 系统能把项目进度反馈给 dashboard。

### 4.5 Growth Dashboard

为什么第五个做：

> Dashboard 要基于真实 profile、path、roadmap、project progress，而不是假进度条。

V1 指标：

- Career Clarity
- Skill Readiness
- Project Readiness
- Resume Readiness
- Networking Readiness
- Interview Readiness
- Execution Consistency

先用规则评分。

验收标准：

- Dashboard 从真实数据计算。
- 显示 strongest area 和 next growth opportunity。
- 显示 this week next action。

### 4.6 AI Advisor

为什么第六个做：

> AI Advisor 必须建立在 profile / roadmap / project progress 上，否则它就是普通聊天框。

V1 功能：

- 读取 profile summary。
- 读取 primary path。
- 读取 current roadmap。
- 读取 current project progress。
- 回答职业/项目/技能相关问题。
- 输出 recommended next action。
- 标记 risk_level。

验收标准：

- 回答能引用学生当前状态。
- 回答会推动下一步。
- 高风险问题会转向 official resource 或 human advisor。

### 4.7 Insight Library / Basic RAG

为什么最后做：

> KB 内容层早就已经在阶段 0 和阶段 3 建好。这里做的是检索层和引用层，也就是让 AI Advisor 能从 KB chunks 里查资料并显示来源。

V1 功能：

- knowledge_sources。
- knowledge_chunks。
- 基础检索。
- 回答显示来源。

验收标准：

- Advisor 能检索至少 20-50 条可靠知识片段。
- 每条来源有 source / license / risk level。
- RAG 没接上时，产品仍然能用 seed KB 跑通 Profile -> Match -> Roadmap -> Project 的核心闭环。

## 阶段 5：信任、合规和安全

这一阶段不是上线后才补。MVP beta 前必须有最小版本。

### 5.1 Consent 和隐私

任务：

- 注册时显示数据用途。
- GPA 只收 range。
- resume / transcript 可选。
- 不默认用于模型训练。
- 用户能删除数据。

验收标准：

- 有 consent_records。
- 有删除入口。
- 有隐私 copy 初版。

### 5.2 AI 安全边界

任务：

- 定义 low / medium / high risk。
- 移民、法律、医疗、心理、保证录取/offer 进入 high risk。
- 高风险答案不下结论，只给官方资源和提问清单。

验收标准：

- Advisor 输出 risk_level。
- 高风险问题测试通过。

### 5.3 Audit logs

任务：

- 记录关键 AI recommendation。
- 记录 profile update。
- 记录 roadmap generation。
- 记录 project feedback。

验收标准：

- 出问题时能回看 AI 用了什么输入，给了什么输出。

## 阶段 6：Beta 测试

目标：验证激活、留存、项目推进和付费意愿。

### 6.1 Beta 用户

目标：

- 100-300 个学生。
- 至少 50 个完整走完 onboarding。
- 至少 30 个进入 roadmap。
- 至少 20 个开始项目。

### 6.2 核心指标

Activation：

- profile completed
- career path selected
- roadmap generated
- first project started

Retention：

- Day 7 return
- Week 4 retention
- weekly task completion

Outcome：

- first project milestone completed
- resume bullet generated
- user reports higher clarity

Trust：

- misleading advice complaint
- high-risk question handling
- data deletion/export request handling

验收标准：

- 40%+ 完整激活：profile + path + first-week plan。
- 25%+ Week 4 retention。
- 30%+ 完成第一个 project milestone。
- 5-10 个明确 willingness-to-pay 信号。

## 阶段 7：商业化试点

目标：把 beta 结果变成可付费场景。

优先路线：

1. Student club cohort。
2. International student group。
3. Career centre small pilot。
4. Youth employment nonprofit。
5. Education / career consulting agency backend。

第一版售卖对象不是“全校 SaaS”，而是：

> AI career clarity + project readiness cohort

试点交付：

- cohort onboarding。
- profile report。
- 4-week roadmap。
- project milestone tracking。
- end-of-cohort report。

验收标准：

- 3-5 个潜在试点方愿意继续聊。
- 至少 1 个付费或准付费试点。
- 有 1-2 个 case study。

## 后续执行规则

之后我按照这个顺序推进：

1. 如果还没有 KB schema 和 seed content，先做 KB，不先写 app。
2. 如果还没有 demo script，先写 demo script，不先做界面。
3. 如果还没有 prototype，先做 clickable prototype，不直接做全功能。
4. 如果进入开发，先做 onboarding/profile，再做 career match。
5. 不在 Profile / Career Match / Roadmap 跑通前做完整 AI Advisor。
6. 不在真实 project progress 存起来前做漂亮 dashboard。
7. 不在 AI Advisor 有真实上下文前做复杂 RAG。
8. 不做家长端、学校端、雇主端、自动投递、全职业库，除非用户明确改 roadmap。

## 现在的下一步

下一步应该做：

> 阶段 0.1 - 0.4：确定第一版 ICP，建立内容库 schema，建立产品数据 schema，写 demo script。

具体交付顺序：

1. `ICP_AND_USER_STORIES_ZH.md`
2. `CONTENT_SCHEMA_ZH.md`
3. `DATA_SCHEMA_ZH.md`
4. `DEMO_SCRIPT_ZH.md`

这四个完成后，再进入访谈问题和 Figma prototype。
